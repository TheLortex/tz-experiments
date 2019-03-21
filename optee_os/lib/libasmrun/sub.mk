BRUNPATH=../libcamlrun/
incdirs-y += $(BRUNPATH)/

UNIX_OR_WIN32=unix
MODEL=default
SYSTEM=elf
TARGET=aarch64-linux-gnu

cppflags-y +=-DNATIVE_CODE -DTARGET_arm64

ifeq "$(UNIX_OR_WIN32)" "unix"
cppflags-y += -DMODEL_$(MODEL)
endif

cppflags-y += -DSYS_$(SYSTEM)
cppflags-y += -g

srcs-y += startup.c
srcs-y += fail.c
srcs-y += roots.c
srcs-y += signals_asm.c
srcs-y += backtrace_prim.c
srcs-y += natdynlink.c
srcs-y += clambda_checks.c
srcs-y += spacetime.c
srcs-y += spacetime_snapshot.c
srcs-y += spacetime_offline.c
srcs-y += arm64.S
subdirs-y += $(BRUNPATH)

cppflags-lib-y =-DCAML_NAME_SPACE

#srcs-y :=
#cflags-y :=
#cflags-lib-y :=
#cppflags-y :=
#cppflags-lib-y :=
#aflags-y :=
#cflags-remove-y :=
#subdirs-y :=
#global-incdirs-y :=
#incdirs-lib-y :=
#incdirs-y :=
#gensrcs-y :=
#this-out-dir :=
#asm-defines-y :=