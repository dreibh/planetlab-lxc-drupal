#
WEBFETCH := curl -H Pragma: -O -R -S --fail --show-error
SHA1SUM	 := sha1sum

version=4.7.11

ALL				+= drupal
# for fedora29
# this patch is about commenting off one line in settings.php:
#this causes a php error in fedora29/php7.2
#ini_set('session.save_handler',     'user');
drupal-URL1		:= http://mirror.onelab.eu/third-party/drupal-$(version)-patch-php72.tar.gz
drupal-SHA1SUM  := f99343938b418384859ff2ced0a0870824e73a13
# so we can no longer use upstream that was here:
#drupal-URL2	:= http://ftp.drupal.org/files/projects/drupal-$(version).tar.gz
drupal			:= drupal-$(version).tar.gz

ALL				+= taxo
taxo-URL1		:= http://mirror.onelab.eu/third-party/taxonomy_block-4.7.x-1.x-dev.tar.gz
taxo-SHA1SUM	:= 9d926df1695c0092a74446154b00579d4ccbcb60
taxo	  		:= $(notdir $(taxo-URL1))

all: $(ALL)
.PHONY: all

##############################
define download_target
$(1): $($(1))
.PHONY: $(1)
$($(1)):
	@if [ ! -e "$($(1))" ] ; then echo "$(WEBFETCH) $($(1)-URL1)" ; $(WEBFETCH) $($(1)-URL1) -o $($(1));  fi
	@if [ ! -e "$($(1))" ] ; then echo "Could not download source file: $($(1)) does not exist" ; exit 1 ; fi
	@if test "$$$$($(SHA1SUM) $($(1)) | awk '{print $$$$1}')" != "$($(1)-SHA1SUM)" ; then \
	    echo "sha1sum of the downloaded $($(1)) does not match the one from 'Makefile'" ; \
	    echo "Local copy: $$$$($(SHA1SUM) $($(1)))" ; \
	    echo "In Makefile: $($(1)-SHA1SUM)" ; \
	    false ; \
	else \
	    ls -l $($(1)) ; \
	fi
endef

$(eval $(call download_target,drupal))
$(eval $(call download_target,taxo))

sources: $(ALL)
.PHONY: sources

####################
# default - overridden by the build
SPECFILE = drupal.spec

PWD=$(shell pwd)
PREPARCH ?= noarch
RPMDIRDEFS = --define "_sourcedir $(PWD)" --define "_builddir $(PWD)" --define "_srcrpmdir $(PWD)" --define "_rpmdir $(PWD)"
trees: sources
	rpmbuild $(RPMDIRDEFS) $(RPMDEFS) --nodeps -bp --target $(PREPARCH) $(SPECFILE)

srpm: sources
	rpmbuild $(RPMDIRDEFS) $(RPMDEFS) --nodeps -bs $(SPECFILE)

TARGET ?= $(shell uname -m)
rpm: sources
	rpmbuild $(RPMDIRDEFS) $(RPMDEFS) --nodeps --target $(TARGET) -bb $(SPECFILE)

clean:
	rm -f *.rpm *.tgz *.bz2 *.gz

++%: varname=$(subst +,,$@)
++%:
	@echo "$(varname)=$($(varname))"
+%: varname=$(subst +,,$@)
+%:
	@echo "$($(varname))"
