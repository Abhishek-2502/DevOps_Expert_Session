class motd($studentname = 'Student') {
  file { 'motd-file':
    ensure  => file,
    path    => $facts['os']['family'] ? {
      'windows' => "D:\Docs\Abhi\CSE\DevSecOps\SIT\DevOps_Expert_Session\Faculty_Repo\DevOps-3rd-Lecture\puppet-demo\motd.txt",
      default   => "/tmp/motd.txt",
    },
    content => epp("D:\Docs\Abhi\CSE\DevSecOps\SIT\DevOps_Expert_Session\Faculty_Repo\DevOps-3rd-Lecture\puppet-demo\motd.epp", { 'studentname' => $studentname }),
  }
}

class { 'motd': studentname => 'Abhishek' }