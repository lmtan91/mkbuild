# Makefile fragment intended to be used with non-recursive makefiles
ifdef RMCH_CONFIG_LOADED

# Add current targets to end of ALL_TARGETS
DIR_TARGETS := \
	$(PLATFORM_TARGET_PROGS) \
	$(PLATFORM_TARGET_LIBS) \
	$(PLATFORM_TARGET_SHLIBS) \
	$(NULL)

ND_DIR_TARGETS := \
	$(PLATFORM_ND_TARGET_PROGS) \
	$(PLATFORM_ND_TARGET_LIBS) \
	$(PLATFORM_ND_TARGET_SHLIBS) \
	$(NULL)

ALL_TARGETS := $(strip $(ALL_TARGETS) $(DIR_TARGETS))

SRCDIR := $(TOPSRCDIR)/$(DIR)
OBJDIR := $(TOPOBJDIR)/$(DIR)
CFLAGS_PROG_$(DIR) += $(patsubst %,-I%, $(INCDIRS_$(DIR)))
DEPS_$(DIR) += $(SRCDIR)/build.mk
DEPS_$(DIR) += $(TOPSRCDIR)/mkbuild/Make.Defaults
DEPS_$(DIR) += $(TOPSRCDIR)/mkbuild/rules.mk
DISTCLEAN_OBJS := $(DISTCLEAN_OBJS) $(wildcard $(OBJDIR)/.objs_*) $(wildcard $(OBJDIR)/.exes_*)

# Generate target definitions
$(foreach t,$(DIR_TARGETS) $(ND_DIR_TARGETS),$(eval $(call gen_target_defs,$(t))))

# Generate rules for each type of target
$(foreach p,$(TARGET_PROGS) $(ND_TARGET_PROGS),$(eval $(call create_rule_target_progs,$(p))))
#
$(foreach p,$(TARGET_LIBS) $(ND_TARGET_LIBS),$(eval $(call create_rule_target_libs,$(p))))

# Include dependency files for each target
GEN_DEPS_$(DIR) := $(foreach t,$(DIR_TARGETS) $(ND_DIR_TARGETS),$(call wildcard_dependencies,$t))
ifneq (,$(strip $(GEN_DEPS_$(DIR))))
include $(GEN_DEPS_$(DIR))
endif

# Unset target variables to avoid tainting next makefile
$(foreach t,DIR SRCDIR OBJDIR DIR_TARGETS TARGET_MODULES TARGET_PROGS TARGET_LIBS TARGET_SHLIBS TARGET_KERNLIBS ND_DIR_TARGETS ND_TARGET_MODULES ND_TARGET_PROGS ND_TARGET_LIBS ND_TARGET_SHLIBS ND_TARGET_KERNLIBS,$(eval $(t) := $(NULL)))

else
# Translation layer for old mkbuild
CFLAGS += $(CFLAGS_$(DIR))
INCDIRS += $(INCDIRS_$(DIR))
MAKEFILE_DEPS += $(DEPS_$(DIR))

endif
