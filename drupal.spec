#
# $Id$
#

%define name drupal
%define version 4.7
%define taglevel 11

%define release %{taglevel}%{?pldistro:.%{pldistro}}%{?date:.%{date}}

Packager: PlanetLab Central <support@planet-lab.org>

# remain compliant with former planetlab practices
%define drupaldir /var/www/html
Name: %{name}
Version:  %{version}
Release:  %{release}
Summary: An open-source content-management platform

Group: Applications/Publishing
License: GPLv2+        
URL: http://www.drupal.org
Source0: http://ftp.osuosl.org/pub/drupal/files/projects/%{name}-%{version}.%{taglevel}.tar.gz
#Source1: drupal.conf
Source2: drupal-cron

BuildArch: noarch
BuildRoot: %{_tmppath}/%{name}-%{version}-%{release}-root-%(%{__id_u} -n)
Requires: php, php-gd, php-mbstring, wget

%description
Equipped with a powerful blend of features, Drupal is a Content Management 
System written in PHP that can support a variety of websites ranging from
personal weblogs to large community-driven websites.  Drupal is highly
configurable, skinnable, and secure.

%prep

%setup -q -n %{name}-%{version}.%{taglevel}

%build

%install
rm -rf %{buildroot}
install -d %{buildroot}%{drupaldir}
cp -pr * %{buildroot}%{drupaldir}
cp -pr .htaccess %{buildroot}%{drupaldir}
mkdir -p %{buildroot}%{_docdir}
install -D -p -m 0644 %{SOURCE2} %{buildroot}%{_sysconfdir}/cron.hourly/drupal 
mkdir %{buildroot}%{drupaldir}/files

%clean
rm -rf %{buildroot}

%files
%defattr(-,root,root,-)
%doc CHANGELOG.txt INSTALL* LICENSE* MAINTAINERS.txt UPGRADE.txt 
%{drupaldir}
%config(noreplace) %{drupaldir}/.htaccess
%exclude %{drupaldir}/CHANGELOG.txt
%exclude %{drupaldir}/INSTALL* 
%exclude %{drupaldir}/LICENSE* 
%exclude %{drupaldir}/MAINTAINERS.txt 
%exclude %{drupaldir}/UPGRADE.txt
%config(noreplace) %{drupaldir}/sites/default
%attr(755,root,apache) %{_sysconfdir}/cron.hourly/drupal
%dir %attr(775,root,apache) %{drupaldir}/files

%changelog
