#!/bin/ksh

export PKG_PATH=http://ftp.NetBSD.org/pub/pkgsrc/packages/NetBSD/$(uname -m)/$(uname -r)/All

pkg_add -v bash
pkg_add -v curl

