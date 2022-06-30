PLUGIN_NAME=        threatpatrols
PLUGIN_VERSION=     0.1.2
PLUGIN_COMMENT=     Vendor repository for Threat Patrols (MultiCLOUDsense, ConfigSync and others)
PLUGIN_MAINTAINER=  contact@threatpatrols.com
PLUGIN_WWW=         https://documentation.threatpatrols.com/opnsense-plugins/
PLUGIN_DEPENDS=     ${PLUGIN_FLAVOUR:tl}

PLUGIN_PREFIX=		os-
PLUGIN_SUFFIX=
PLUGIN_DEVEL=       no

.include "../../Mk/plugins.mk"
