#!/usr/bin/env bash

if [[ $EUID -ne 0 ]]; then
   	echo "This script must be run as root"
   	exit 1
else
	#Update and Upgrade
	echo "Updating and Upgrading"
	sudo apt-get update && sudo apt-get dist-upgrade && sudo apt-get autoremove -y

	sudo apt-get install dialog
	cmd=(dialog --separate-output --checklist "Please Select Software you want to install:" 22 76 16)
	options=(
	         1 "LAMP Stack" on
	         2 "Git" on
			 3 "Python3" on
			 4 "Python3-pip" on
	         5 "Composer" on
	         6 "Memcached" off
	         7 "JDK 8" on
	         8 "JQ" off
	         9 "Google Chrome" off
			 10 "Silver Searcher (ag)" on
			 11 "Expect" off
			)
		choices=$("${cmd[@]}" "${options[@]}" 2>&1 >/dev/tty)
		clear

		for choice in ${choices}
		do
		    case ${choice} in

            1)
                #Install LAMP stack
                echo "Installing Apache"
                apt install apache2 -y

                echo "Installing Mysql Server"
                apt install mysql-server mysql-client -y

                echo "Installing PHP"
                apt install php libapache2-mod-php php-mcrypt php-mysql -y

                echo "Installing Phpmyadmin"
                apt install phpmyadmin -y

                echo "Cofiguring apache to run Phpmyadmin"
                echo "Include /etc/phpmyadmin/apache.conf" >> /etc/apache2/apache2.conf

                echo "Enabling module rewrite"
                sudo a2enmod rewrite
                # sudo vi /etc/apache2/apache2.conf
                # （没有的话，可以尝试sudo vi /etc/apache2/sites-available/000-default.conf）
                # 打开apache配置文件

                #实际目录根据网站根目录而定
                #<Directory /var/www/>
                #
                #    #Options Indexes FollowSymLinks
                #    Options FollowSymLinks # 删除 Indexes,禁止 Apache 显示目录索引
                #    AllowOverride None  #改为 All
                #    Require all granted
                #
                #</Directory>

                echo "Restarting Apache Server"
                service apache2 restart
				;;


    		2)
				#Install git
				echo "Installing Git, please congiure git later..."
				apt install git -y
				;;

			3)
				#Install Python3
				echo "Installing Python3"
				apt install software-properties-common
                add-apt-repository ppa:deadsnakes/ppa
                apt update
                apt install python3.6
				;;

			4)
				#Install python3-pip
				echo "Installing python3-pip"
				sudo apt install python3-pip -y
				;;

			5)
				#Composer
				echo "Installing Composer"
				EXPECTED_SIGNATURE=$(wget https://composer.github.io/installer.sig -O - -q)
				php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');"
				ACTUAL_SIGNATURE=$(php -r "echo hash_file('SHA384', 'composer-setup.php');")

				if [ "$EXPECTED_SIGNATURE" = "$ACTUAL_SIGNATURE" ]
				  then
				php composer-setup.php --quiet --install-dir=/bin --filename=composer
				RESULT=$?
				rm composer-setup.php
				else
				  >&2 echo 'ERROR: Invalid installer signature'
				  rm composer-setup.php
				fi
				;;

			6)
				#Install memcached
				echo "Installing memcached"
				apt update
                add-apt-repository ppa:ondrej/php
                apt update
                apt upgrade
                apt install memcached

                #https://github.com/fwolf/memcached-client
                #if(class_exists('Memcache')){
                #  // Memcache is enabled.
                #}
                #$m = new Memcached();
                #$m->addServer('localhost', 11211);
                #
                #$m->set('foo', 'bar');
                #$m->get('foo');

                #sudo service memcached stop
                #sudo service memcached start
                #sudo service memcached restart
				;;

			7)
				#JDK 8
				echo "Installing JDK 8"
				apt install python-software-properties -y
				add-apt-repository ppa:webupd8team/java -y
				apt update
				apt install oracle-java8-installer -y
				;;

			8)
				#JQ
				echo "Installing JQ"
				apt install jq -y
				;;

			9)
				#Chrome
				echo "Installing Google Chrome"
				wget -q -O - https://dl-ssl.google.com/linux/linux_signing_key.pub | sudo apt-key add -
				sh -c 'echo "deb [arch=amd64] http://dl.google.com/linux/chrome/deb/ stable main" >> /etc/apt/sources.list.d/google-chrome.list'
				apt-get update
				apt-get install google-chrome-stable -y
				;;

			10)
				#Silver Searcher
				echo "Installing Silver Searcher"
				apt-get install silversearcher-ag -y
				;;

			11)
				#expect
				echo "Installing expect"
				apt install expect -y
				;;
	    esac
	done
fi
