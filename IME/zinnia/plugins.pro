 TEMPLATE = lib
 CONFIG += qt plugin
 QT += declarative

 DESTDIR = org/slatekit/Zinnia
 TARGET  = qmlzinniaplugin

 SOURCES += plugin.cpp

 qdeclarativesources.files += org/slatekit/Zinnia/qmldir 

# qdeclarativesources.path += $$[QT_INSTALL_EXAMPLES]/declarative/plugins/org/slatekit/Zinnia

 sources.files += plugins.pro plugin.cpp
 sources.path += $$[QT_INSTALL_EXAMPLES]/declarative/plugins
 target.path += $$[QT_INSTALL_EXAMPLES]/declarative/plugins/org/slatekit/Zinnia

 INSTALLS += qdeclarativesources sources target

unix {
    CONFIG += link_pkgconfig
    PKGCONFIG += zinnia
}


