#
# spec file for package monpetitami
#
# This file and all modifications and additions to the pristine
# package are under the same license as the package itself.
#
# please send bugfixes or comments to arnaubria@pic.es

%define _cgi_dir /var/www/cgi-bin


Name:		monpetitami
Version:	0.0.4
Release:	3
Summary:	SGE or torque/maui monitoring tool
Group:		Administration Tools
License:	GPL
URL:		https://github.com/pelacables/monpetitami
Source0:	%{name}-%{version}-%{release}.tar.gz
BuildRoot:	%{_tmppath}/%{name}-%{version}-%{release}-root-%(%{__id_u} -n)

AutoReqProv: 	no
Requires:	perl(PBS)
Requires:	perl(RRD::Simple)
Requires:	perl(Proc::PID::File) >= 1.20
Requires:	perl(YAML)
Requires:	perl(Log::Dispatch)


%description
Monpetitami is a monitoring system for SGE or TORQUE/Maui jobs and Priority FS. It runs as a daemon under special monpetitami user.

%prep
%setup -q -n %{name}-%{version}-%{release}

%install
rm -rf %{buildroot}
echo %{buildroot}
mkdir -p %{buildroot}{%{_sysconfdir},/bin,/usr/bin}
mkdir -p %{buildroot}%{_sysconfdir}/monpetitami.d
mkdir -p %{buildroot}%{_sysconfdir}/init.d
mkdir -p %{buildroot}%{_sysconfdir}/logrotate.d
mkdir -p %{buildroot}%{_cgi_dir}
mkdir -p %{buildroot}/var/run/monpetitami
mkdir -p %{buildroot}/usr/share/man/man8
mkdir -p %{buildroot}/var/log/monpetitami
cp bin/monpetitami %{buildroot}/bin
cp usr/bin/ganglia_groups.sh %{buildroot}/usr/bin
cp etc/monpetitami.d/colors20 %{buildroot}%{_sysconfdir}/monpetitami.d/ 
cp etc/monpetitami.d/colors50 %{buildroot}%{_sysconfdir}/monpetitami.d/
cp etc/monpetitami.d/colors80 %{buildroot}%{_sysconfdir}/monpetitami.d/
cp etc/monpetitami.conf %{buildroot}%{_sysconfdir}/
cp etc/init.d/monpetitami %{buildroot}%{_sysconfdir}/init.d/
cp etc/logrotate.d/monpetitami %{buildroot}%{_sysconfdir}/logrotate.d/
cp var/www/cgi-bin/monpetitami.pl %{buildroot}/%{_cgi_dir}/
cp usr/share/man/man8/monpetitami.gz %{buildroot}/usr/share/man/man8/

%pre
if [ "$1" -eq "1" ]; then
  /usr/sbin/useradd -c "MonAMI monitoring daemon" -r monpetitami || :
fi
mkdir -p /var/log/monpetitami/
chown monpetitami:monpetitami /var/log/monpetitami/

%post
if [ "$1" -eq "1" ]; then
  #  Register our monami service
  /sbin/chkconfig --add monpetitami
fi


%files
%defattr(-,root,root,-)
%attr(0755, root,root) /bin/monpetitami
%attr(0755, root,root) /etc/init.d/monpetitami
%attr(0755, root,root) /etc/logrotate.d/monpetitami
%attr(0640, monpetitami,monpetitami) /etc/monpetitami.conf
%attr(0755, root,root) /var/www/cgi-bin/monpetitami.pl
%attr(0755, root,root) /usr/bin/ganglia_groups.sh
%attr(0755, root,root) /etc/monpetitami.d/
%attr(0640, monpetitami,monpetitami) /etc/monpetitami.d/colors20 
%attr(0640, monpetitami,monpetitami) /etc/monpetitami.d/colors50
%attr(0640, monpetitami,monpetitami) /etc/monpetitami.d/colors80
%attr(0640, monpetitami,monpetitami) /var/run/monpetitami
%attr(0640, monpetitami,monpetitami) /var/log/monpetitami
%attr(0444, root,root) /usr/share/man/man8/monpetitami.gz

#%clean
#rm -rf %{buildroot}

%changelog
* Tue Feb 12 2013 Arnau Bria <arnau.bria@gmail.com> 0.0.4
- Added Job Array support

* Thu Jan 23 2013 Arnau Bria <arnau.bria@gmail.com> 0.0.4
- incorrect for bucle for parsing a hash reference
- logrotate restarts monpetitami daemon without environment. 
- qw status cannot be an "=", it must be "!~" cause also exists Eqw, hqw ...

* Thu Jan 10 2013 Arnau Bria <arnau.bria@gmail.com> 0.0.4
- Added SGE support

* Tue Sep 04 2012 Arnau Bria <arnaubria@pic.es> 0.0.3
- Added Eff by group
- Help / man
- Removed groups.yaml queues.yaml files
- Added script that geenrates ganglia's json file

* Tue Mar 27 2012 Arnau Bria <arnaubria@pic.es> 0.0.2
- Correct diagnose call (fork + exec + pipe)
- Added logrotate

* Mon Mar 5 2012 Arnau Bria <arnaubria@pic.es> 0.0.1
- First release
