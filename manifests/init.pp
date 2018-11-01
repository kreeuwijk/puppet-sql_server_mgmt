# Manages SQL server configuration
#
# @summary Manages SQL server configuration
#
# @example
#   include sqlserver_mgmt
class sqlserver_mgmt (
  $configs        = {},
  $databases      = {},
  $logins         = {},
  $users          = {},
  $db_defaults    = {},
  $login_defaults = {},
  $user_defaults  = {},
){
  # Define access to SQL instance(s)
  $configs.each |$name, $attribs| {
    sqlserver::config {
      $name:
        * => $attribs
    }
  }

  # Create database(s)
  $databases.each |$name, $attribs| {
    if $attribs != undef {
      # Create the database with specified attributes
      sqlserver::database{
        default:
          *       => $db_defaults
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
          *       => $db_defaults
          ;
        $name:
      }
    }
  }
  # Create SQL Login(s)
  $logins.each |$name, $attribs| {
    if $attribs != undef {
      # Create the login with specified attributes
      sqlserver::login{
        default:
          *       => $login_defaults
          ;
        $name:
          * => $attribs
      }
    }
    else {
      # Create the login with only default attributes
      sqlserver::login{
        default:
          *       => $login_defaults
          ;
        $name:
      }
    }
  }

  # Create SQL User(s)
  $users.each |$name, $attribs| {
    if $attribs != undef {
      # Emulate sqlserver module behavior: if 'login' is not specified, assume the user and login are the same
      if $attribs['login'] != undef {
        $sqllogin = $attribs['login']
      }
      else {
        $sqllogin = $attribs['user']
      }
      # Create the user with specified attributes
      sqlserver::user{
        default:
          *       => $user_defaults
          ;
        $name:
          *       => delete($attribs, ['permissions']),
          require => Sqlserver::Login[$sqllogin]
      }
    }
    else {
      # Emulate sqlserver module behavior: if 'login' is not specified, assume the user and login are the same
      if $user_defaults['login'] != undef {
        $sqllogin = $user_defaults['login']
      }
      elsif $user_defaults['user'] != undef {
        $sqllogin = $user_defaults['user']
      }
      else {
        $sqllogin = $name
      }
      # Create the database with only default attributes
      sqlserver::user{
        default:
          *       => $user_defaults
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
