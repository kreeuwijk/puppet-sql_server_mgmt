# Manages SQL server configuration
#
# @summary Manages SQL server configuration
#
# @example
#   include sql_server_mgmt
class sql_server_mgmt (
  $sql_config = lookup('sql', Hash, 'hash', { 'configs' => {}, 'databases' => {}, 'logins' => {}, 'users' => {} })
){
  # Define access to SQL instance(s)
  $sql_config['configs'].each |$name, $attribs| {
    sqlserver::config {
      $name:
        * => $attribs
    }
  }

  # Create database(s)
  $sql_config['databases'].each |$name, $attribs| {
    if $name != '_default'{
      if $attribs != undef {
        # Create the database with specified attributes
        sqlserver::database{
          default:
            *       => $sql_config['databases']['_default']
            ;
          $name:
            * => delete($attribs, ['template', 'restorefrom', 'backupto'])
        }
        # Apply database template from a .sql file if specified
        if ($attribs['template'] != undef) and ($attribs['ensure'] !='absent') {
          $template_epp = epp($attribs['template'])
          $marker_epp   = epp("${module_name}/template_marker.sql.epp", {'dbname' => $name})
          sqlserver_tsql { "TemplateDB-${name}":
            instance => $attribs['instance'],
            command  => "${template_epp}${marker_epp}",
            onlyif   => "USE ${name}; IF not exists (select * from sys.extended_properties where NAME = 'templated_by_puppet') THROW 50000, '${name} will be altered to template', 10",
            require  => [
              Sqlserver::Config[$attribs['instance']],
              Sqlserver::Database[$name],
            ]
          }
        }
        # Restore database from a backup file if specified
        if ($attribs['restorefrom'] != undef) and ($attribs['ensure'] !='absent') {
          sqlserver_tsql { "RestoreDB-${name}":
            instance => $attribs['instance'],
            command  => epp("${module_name}/restore_db.sql.epp", {'backupfile' => $attribs['restorefrom'], 'dbname' => $name}),
            onlyif   => "USE ${name}; IF not exists (select * from sys.extended_properties where NAME = 'restored_by_puppet') THROW 50000, '${name} will be restored', 10",
            require  => [
              Sqlserver::Config[$attribs['instance']],
              Sqlserver::Database[$name],
            ]
          }
        }
        # Backup database to a backup file if specified
        if ($attribs['backupto'] != undef) and ($attribs['ensure'] !='absent') {
          sqlserver_tsql { "BackupDB-${name}":
            instance => $attribs['instance'],
            command  => epp("${module_name}/backup_db.sql.epp", {'backupfile' => $attribs['backupto'], 'dbname' => $name}),
            onlyif   => "USE ${name}; IF not exists (select * from sys.extended_properties where NAME = 'backed_up_by_puppet') THROW 50000, '${name} will be backed up', 10",
            require  => [
              Sqlserver::Config[$attribs['instance']],
              Sqlserver::Database[$name],
            ]
          }
        }
      }
      else {
        # Create the database with only default attributes
        sqlserver::database{
          default:
            *       => $sql_config['databases']['_default']
            ;
          $name:
        }
      }
    }
  }
  # Create SQL Login(s)
  $sql_config['logins'].each |$name, $attribs| {
    if $name != '_default'{
      if $attribs != undef {
        # Create the login with specified attributes
        sqlserver::login{
          default:
            *       => $sql_config['logins']['_default']
            ;
          $name:
            * => $attribs
        }
      }
      else {
        # Create the login with only default attributes
        sqlserver::login{
          default:
            *       => $sql_config['logins']['_default']
            ;
          $name:
        }
      }
    }
  }

  # Create SQL User(s)
  $sql_config['users'].each |$name, $attribs| {
    if $name != '_default'{
      if $attribs != undef {
        # Emulate sql_server module behavior: if 'login' is not specified, assume the user and login are the same
        if $attribs['login'] != undef {
          $sqllogin = $attribs['login']
        }
        else {
          $sqllogin = $attribs['user']
        }
        # Create the user with specified attributes
        sqlserver::user{
          default:
            *       => $sql_config['users']['_default']
            ;
          $name:
            *       => delete($attribs, ['permissions']),
            require => Sqlserver::Login[$sqllogin]
        }
      }
      else {
        # Emulate sql_server module behavior: if 'login' is not specified, assume the user and login are the same
        if $sql_config['users']['_default']['login'] != undef {
          $sqllogin = $sql_config['users']['_default']['login']
        }
        elsif $sql_config['users']['_default']['user'] != undef {
          $sqllogin = $sql_config['users']['_default']['user']
        }
        else {
          $sqllogin = $name
        }
        # Create the database with only default attributes
        sqlserver::user{
          default:
            *       => $sql_config['users']['_default']
            ;
          $name:
            require  => Sqlserver::Login[$sqllogin]
        }
      }
      # Apply SQL User Permission(s) if specified
      $attribs['permissions'].each |$type, $permissions| {
        sqlserver::user::permissions{
          "${type}-${name}-on-${attribs['database']}":
            user        => $attribs['user'],
            database    => $attribs['database'],
            instance    => $attribs['instance'],
            permissions => $permissions,
            state       => $type,
            require     => Sqlserver::User[$name],
        }
      }
    }
  }
}
