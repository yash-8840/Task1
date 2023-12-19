#!/bin/bash

# Section A

if [[ $1 == "--help" ]]; then
  echo "Usage: internsctl [options]"
  echo "Options:"
  echo "  --help           Display this help message"
  echo "  --version        Display the command version"
  echo "  --man            Display the manual page"
  echo "  --size           Diaplay the file size"
  echo "  --permissions    Display the file permissions"
  echo "  --owner          Display the file owner"
  echo "  --last-modified  Display the last modified"
  exit 0
fi

if [[ $1 == "--version" ]]; then
  echo "internsctl v0.1.0"
  exit 0
fi

if [[ $1 == "--man" ]]; then
  echo "INTERNSTL(1)                     User Commands                     INTERNSTL(1)"
  echo ""
  echo "NAME"
  echo "    internsctl - Custom Linux command for operations"
  echo ""
  echo "SYNOPSIS"
  echo "    internsctl [options]"
  echo ""
  echo "DESCRIPTION"
  echo "    The internsctl command provides various options for performing operations."
  echo ""
  echo "OPTIONS"
  echo "    --help     Display the help message and usage guidelines."
  echo ""
  echo "    --version  Display the command version."
  echo ""
  echo "    --man      Display the manual page."
  echo ""
  echo "EXAMPLES"
  echo "    internsctl cpu getinfo        Get CPU information of the server."
  echo ""
  echo "    internsctl memory getinfo     Get memory information of the server."
  echo ""
  echo "    internsctl user create <username>   Create a new user on the server."
  echo ""
  echo "    internsctl user list          List all regular users on the server."
  echo ""
  echo "    internsctl user list --sudo-only    List users with sudo permissions on the server."
  echo ""
  echo "    internsctl file getinfo [options] <file-name>    Get information about a file."
  echo ""
  exit 0
fi

# Section B

if [[ $1 == "cpu" && $2 == "getinfo" ]]; then
  lscpu
  exit 0
fi

if [[ $1 == "memory" && $2 == "getinfo" ]]; then
  free
  exit 0
fi

if [[ $1 == "user" && $2 == "create" ]]; then
  if [[ -z $3 ]]; then
    echo "Error: Username not provided. Usage: internsctl user create <username>"
    exit 1
  fi

  # Create user
  sudo useradd -m $3
  sudo passwd $3
  exit 0
fi

if [[ $1 == "user" && $2 == "list" ]]; then
  if [[ $3 == "--sudo-only" ]]; then
    # List users with sudo permissions
    sudo awk -F: '$3 >= 1000 && $7 != "/usr/sbin/nologin" { print $1 }' /etc/passwd
  else
    # List all regular users
    awk -F: '$3 >= 1000 && $7 != "/usr/sbin/nologin" { print $1 }' /etc/passwd
  fi
  exit 0
fi

if [[ $1 == "file" && $2 == "getinfo" ]]; then
  if [[ -z $3 ]]; then
    echo "Error: File name not provided. Usage: internsctl file getinfo [options] <file-name>"
    exit 1
  fi

  file_info=$(stat -c "File: %n%nAccess: %A%nSize(B): %s%nOwner: %U%nModify: %y" "$3")

  if [[ -n $4 ]]; then
    case $4 in
      --size | -s)
        size=$(stat -c "%s" "$3")
        echo "Size(B): $size"
        exit 0
        ;;
      --permissions | -p)
        permissions=$(stat -c "%A" "$3")
        echo "Access: $permissions"
        exit 0
        ;;
      --owner | -o)
        owner=$(stat -c "%U" "$3")
        echo "Owner: $owner"
        exit 0
        ;;
      --last-modified | -m)
        last_modified=$(stat -c "%y" "$3")
        echo "Modify: $last_modified"
        exit 0
        ;;
      *)
        echo "Invalid option. Usage: internsctl file getinfo [options] <file-name>"
        exit 1
        ;;
    esac
  else
    echo "$file_info"
    exit 0
  fi
fi

# Invalid command or options

echo "Invalid command or options. Use 'internsctl --help' for more information."
exit 1