class mydemo {
  file { 'demo-dir':
    ensure => directory,
    path   => "D:\Docs\Abhi\CSE\DevSecOps\SIT\DevOps_Expert_Session\Faculty_Repo\DevOps-3rd-Lecture\puppet-demo",
  }

  file { 'demo-file':
    ensure  => file,
    path    => "D:\Docs\Abhi\CSE\DevSecOps\SIT\DevOps_Expert_Session\Faculty_Repo\DevOps-3rd-Lecture\puppet-demo\demo.txt",
    content => "This file is managed by Puppet\n",
    require => File['demo-dir'],   # makes sure folder is created first
  }
}

include mydemo