Return-Path: <linux-ia64-owner@vger.kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from vger.kernel.org (vger.kernel.org [23.128.96.18])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 22D4FC001B0
	for <linux-ia64@archiver.kernel.org>; Thu, 10 Aug 2023 17:18:54 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S231994AbjHJRSx (ORCPT <rfc822;linux-ia64@archiver.kernel.org>);
        Thu, 10 Aug 2023 13:18:53 -0400
Received: from lindbergh.monkeyblade.net ([23.128.96.19]:43048 "EHLO
        lindbergh.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S230327AbjHJRSx (ORCPT
        <rfc822;linux-ia64@vger.kernel.org>); Thu, 10 Aug 2023 13:18:53 -0400
Received: from dfw.source.kernel.org (dfw.source.kernel.org [IPv6:2604:1380:4641:c500::1])
        by lindbergh.monkeyblade.net (Postfix) with ESMTPS id 1D2BE2703
        for <linux-ia64@vger.kernel.org>; Thu, 10 Aug 2023 10:18:52 -0700 (PDT)
Received: from smtp.kernel.org (relay.kernel.org [52.25.139.140])
        (using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
         key-exchange X25519 server-signature RSA-PSS (2048 bits))
        (No client certificate requested)
        by dfw.source.kernel.org (Postfix) with ESMTPS id 982BD6647B
        for <linux-ia64@vger.kernel.org>; Thu, 10 Aug 2023 17:18:51 +0000 (UTC)
Received: by smtp.kernel.org (Postfix) with ESMTPSA id A3E08C433C8;
        Thu, 10 Aug 2023 17:18:50 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
        s=k20201202; t=1691687931;
        bh=10AvcJouEa6XbF73FPgszdI34wCmZF32pvDBb8MhIJ0=;
        h=Date:From:To:Cc:Subject:References:In-Reply-To:From;
        b=nWMLFMIX07czGLY8o+PZ25+VY8NNOkNYrU8WrMuo7zpvJMvA1LCdIHDMIPO1ZCHGg
         8UcFmlEtZGen+tZvu4lmZcGrJwKXdaAXnodcA4AiIBCKQ7vnVVoV6z6V5nVD1yrjGU
         hMw2EZrHZOFO4EKQS4uMHzJPgjaChQfLCNuwuOJ3iBYt4n3fAu/mxFEstZ42V5OKzU
         KGe7p5Cts4eH4ZYso/s5f5feY7rlxy4idUyi1x8uYEnzLZuG+dRDtEC7aEa3Y1aHYm
         lhcBJ8tDIao96a38VGdm/Vd9pTUUIq64Q0YrGNKOedFATjajRSbJO1WOySzsm6oGjo
         f8aDMYhDMrVwA==
Date:   Thu, 10 Aug 2023 10:18:48 -0700
From:   Nathan Chancellor <nathan@kernel.org>
To:     kernel test robot <lkp@intel.com>
Cc:     Tony Luck <tony.luck@intel.com>, llvm@lists.linux.dev,
        oe-kbuild-all@lists.linux.dev, linux-ia64@vger.kernel.org
Subject: Re: [aegl:resctrl2_v65rc4 2/2]
 fs/resctrl2/arch/x86/l3_pseudolock.c:569:1: error: expected ';' after top
 level declarator
Message-ID: <20230810171848.GA628575@dev-arch.thelio-3990X>
References: <202308040650.ayL6ExhZ-lkp@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <202308040650.ayL6ExhZ-lkp@intel.com>
Precedence: bulk
List-ID: <linux-ia64.vger.kernel.org>
X-Mailing-List: linux-ia64@vger.kernel.org

On Fri, Aug 04, 2023 at 06:45:45AM +0800, kernel test robot wrote:
> tree:   https://git.kernel.org/pub/scm/linux/kernel/git/aegl/linux.git resctrl2_v65rc4
> head:   36621209814f9810feed9af60d278a198847c117
> commit: 36621209814f9810feed9af60d278a198847c117 [2/2] resctrl2: Arch x86 modules for most of the legacy control/monitor functions
> config: i386-randconfig-r032-20230804 (https://download.01.org/0day-ci/archive/20230804/202308040650.ayL6ExhZ-lkp@intel.com/config)
> compiler: clang version 16.0.4 (https://github.com/llvm/llvm-project.git ae42196bc493ffe877a7e3dff8be32035dea4d07)
> reproduce: (https://download.01.org/0day-ci/archive/20230804/202308040650.ayL6ExhZ-lkp@intel.com/reproduce)
> 
> If you fix the issue in a separate patch/commit (i.e. not just a new version of
> the same patch/commit), kindly add following tags
> | Reported-by: kernel test robot <lkp@intel.com>
> | Closes: https://lore.kernel.org/oe-kbuild-all/202308040650.ayL6ExhZ-lkp@intel.com/
> 
> All errors (new ones prefixed by >>):
> 
>    fs/resctrl2/arch/x86/l3_pseudolock.c:569:1: warning: '__cold__' attribute only applies to functions [-Wignored-attributes]
>    module_init(cat_init);
>    ^
>    include/linux/module.h:88:24: note: expanded from macro 'module_init'
>    #define module_init(x)  __initcall(x);
>                            ^
>    include/linux/init.h:316:24: note: expanded from macro '__initcall'
>    #define __initcall(fn) device_initcall(fn)
>                           ^
>    include/linux/init.h:311:30: note: expanded from macro 'device_initcall'
>    #define device_initcall(fn)             __define_initcall(fn, 6)
>                                            ^
>    note: (skipping 4 expansions in backtrace; use -fmacro-backtrace-limit=0 to see all)
>    include/linux/init.h:243:6: note: expanded from macro '__define_initcall_stub'
>            int __init __stub(void);                                \
>                ^
>    include/linux/init.h:52:41: note: expanded from macro '__init'
>    #define __init          __section(".init.text") __cold  __latent_entropy __noinitretpoline
>                                                    ^
>    include/linux/compiler_types.h:104:34: note: expanded from macro '__cold'
>    #define __cold                          __attribute__((__cold__))
>                                                           ^
> >> fs/resctrl2/arch/x86/l3_pseudolock.c:569:1: error: expected ';' after top level declarator
>    include/linux/module.h:88:24: note: expanded from macro 'module_init'
>    #define module_init(x)  __initcall(x);
>                            ^
>    include/linux/init.h:316:24: note: expanded from macro '__initcall'
>    #define __initcall(fn) device_initcall(fn)
>                           ^
>    include/linux/init.h:311:30: note: expanded from macro 'device_initcall'
>    #define device_initcall(fn)             __define_initcall(fn, 6)
>                                            ^
>    note: (skipping 1 expansions in backtrace; use -fmacro-backtrace-limit=0 to see all)
>    include/linux/init.h:280:35: note: expanded from macro '___define_initcall'
>            __unique_initcall(fn, id, __sec, __initcall_id(fn))
>                                             ^
>    include/linux/init.h:209:10: note: expanded from macro '__initcall_id'
>            __PASTE(__KBUILD_MODNAME,                               \
>                    ^
>    <command line>:9:48: note: expanded from macro '__KBUILD_MODNAME'
>    #define __KBUILD_MODNAME kmod_rdt_l2_pseudolock:rdt_l3_pseudolock
>                                                   ^
> >> fs/resctrl2/arch/x86/l3_pseudolock.c:569:1: error: type specifier missing, defaults to 'int'; ISO C99 and later do not support implicit int [-Wimplicit-int]
>    include/linux/module.h:88:24: note: expanded from macro 'module_init'
>    #define module_init(x)  __initcall(x);
>                            ^
>    include/linux/init.h:316:24: note: expanded from macro '__initcall'
>    #define __initcall(fn) device_initcall(fn)
>                           ^
>    include/linux/init.h:311:30: note: expanded from macro 'device_initcall'
>    #define device_initcall(fn)             __define_initcall(fn, 6)
>                                            ^
>    note: (skipping 5 expansions in backtrace; use -fmacro-backtrace-limit=0 to see all)
>    include/linux/compiler_types.h:75:22: note: expanded from macro '__PASTE'
>    #define __PASTE(a,b) ___PASTE(a,b)
>                         ^
>    include/linux/compiler_types.h:74:23: note: expanded from macro '___PASTE'
>    #define ___PASTE(a,b) a##b
>                          ^
>    <scratch space>:15:1: note: expanded from here
>    rdt_l3_pseudolock__215_569_cat_init6
>    ^
>    fs/resctrl2/arch/x86/l3_pseudolock.c:569:1: warning: '__cold__' attribute only applies to functions [-Wignored-attributes]
>    include/linux/module.h:88:24: note: expanded from macro 'module_init'
>    #define module_init(x)  __initcall(x);
>                            ^
>    include/linux/init.h:316:24: note: expanded from macro '__initcall'
>    #define __initcall(fn) device_initcall(fn)
>                           ^
>    include/linux/init.h:311:30: note: expanded from macro 'device_initcall'
>    #define device_initcall(fn)             __define_initcall(fn, 6)
>                                            ^
>    note: (skipping 4 expansions in backtrace; use -fmacro-backtrace-limit=0 to see all)
>    include/linux/init.h:244:6: note: expanded from macro '__define_initcall_stub'
>            int __init __stub(void)                                 \
>                ^
>    include/linux/init.h:52:41: note: expanded from macro '__init'
>    #define __init          __section(".init.text") __cold  __latent_entropy __noinitretpoline
>                                                    ^
>    include/linux/compiler_types.h:104:34: note: expanded from macro '__cold'
>    #define __cold                          __attribute__((__cold__))
>                                                           ^
> >> fs/resctrl2/arch/x86/l3_pseudolock.c:569:1: error: expected ';' after top level declarator
>    include/linux/module.h:88:24: note: expanded from macro 'module_init'
>    #define module_init(x)  __initcall(x);
>                            ^
>    include/linux/init.h:316:24: note: expanded from macro '__initcall'
>    #define __initcall(fn) device_initcall(fn)
>                           ^
>    include/linux/init.h:311:30: note: expanded from macro 'device_initcall'
>    #define device_initcall(fn)             __define_initcall(fn, 6)
>                                            ^
>    note: (skipping 1 expansions in backtrace; use -fmacro-backtrace-limit=0 to see all)
>    include/linux/init.h:280:35: note: expanded from macro '___define_initcall'
>            __unique_initcall(fn, id, __sec, __initcall_id(fn))
>                                             ^
>    include/linux/init.h:209:10: note: expanded from macro '__initcall_id'
>            __PASTE(__KBUILD_MODNAME,                               \
>                    ^
>    <command line>:9:48: note: expanded from macro '__KBUILD_MODNAME'
>    #define __KBUILD_MODNAME kmod_rdt_l2_pseudolock:rdt_l3_pseudolock
>                                                   ^
> >> fs/resctrl2/arch/x86/l3_pseudolock.c:569:1: error: type specifier missing, defaults to 'int'; ISO C99 and later do not support implicit int [-Wimplicit-int]
>    include/linux/module.h:88:24: note: expanded from macro 'module_init'
>    #define module_init(x)  __initcall(x);
>                            ^
>    include/linux/init.h:316:24: note: expanded from macro '__initcall'
>    #define __initcall(fn) device_initcall(fn)
>                           ^
>    include/linux/init.h:311:30: note: expanded from macro 'device_initcall'
>    #define device_initcall(fn)             __define_initcall(fn, 6)
>                                            ^
>    note: (skipping 5 expansions in backtrace; use -fmacro-backtrace-limit=0 to see all)
>    include/linux/compiler_types.h:75:22: note: expanded from macro '__PASTE'
>    #define __PASTE(a,b) ___PASTE(a,b)
>                         ^
>    include/linux/compiler_types.h:74:23: note: expanded from macro '___PASTE'
>    #define ___PASTE(a,b) a##b
>                          ^
>    <scratch space>:15:1: note: expanded from here
>    rdt_l3_pseudolock__215_569_cat_init6
>    ^
> >> fs/resctrl2/arch/x86/l3_pseudolock.c:569:1: error: expected ';' after top level declarator
>    include/linux/module.h:88:24: note: expanded from macro 'module_init'
>    #define module_init(x)  __initcall(x);
>                            ^
>    include/linux/init.h:316:24: note: expanded from macro '__initcall'
>    #define __initcall(fn) device_initcall(fn)
>                           ^
>    include/linux/init.h:311:30: note: expanded from macro 'device_initcall'
>    #define device_initcall(fn)             __define_initcall(fn, 6)
>                                            ^
>    note: (skipping 1 expansions in backtrace; use -fmacro-backtrace-limit=0 to see all)
>    include/linux/init.h:280:35: note: expanded from macro '___define_initcall'
>            __unique_initcall(fn, id, __sec, __initcall_id(fn))
>                                             ^
>    include/linux/init.h:209:10: note: expanded from macro '__initcall_id'
>            __PASTE(__KBUILD_MODNAME,                               \
>                    ^
>    <command line>:9:48: note: expanded from macro '__KBUILD_MODNAME'
>    #define __KBUILD_MODNAME kmod_rdt_l2_pseudolock:rdt_l3_pseudolock
>                                                   ^
> >> fs/resctrl2/arch/x86/l3_pseudolock.c:569:1: error: type specifier missing, defaults to 'int'; ISO C99 and later do not support implicit int [-Wimplicit-int]
>    include/linux/module.h:88:24: note: expanded from macro 'module_init'
>    #define module_init(x)  __initcall(x);
>                            ^
>    include/linux/init.h:316:24: note: expanded from macro '__initcall'
>    #define __initcall(fn) device_initcall(fn)
>                           ^
>    include/linux/init.h:311:30: note: expanded from macro 'device_initcall'
>    #define device_initcall(fn)             __define_initcall(fn, 6)
>                                            ^
>    note: (skipping 8 expansions in backtrace; use -fmacro-backtrace-limit=0 to see all)
>    include/linux/compiler_types.h:75:22: note: expanded from macro '__PASTE'
>    #define __PASTE(a,b) ___PASTE(a,b)
>                         ^
>    include/linux/compiler_types.h:74:23: note: expanded from macro '___PASTE'
>    #define ___PASTE(a,b) a##b
>                          ^
>    <scratch space>:28:1: note: expanded from here
>    rdt_l3_pseudolock__215_569_cat_init6216
>    ^
> >> fs/resctrl2/arch/x86/l3_pseudolock.c:569:1: error: incompatible pointer to integer conversion initializing 'int' with an expression of type 'void *' [-Wint-conversion]
>    module_init(cat_init);
>    ^~~~~~~~~~~~~~~~~~~~~
>    include/linux/module.h:88:24: note: expanded from macro 'module_init'
>    #define module_init(x)  __initcall(x);
>                            ^~~~~~~~~~~~~
>    include/linux/init.h:316:24: note: expanded from macro '__initcall'
>    #define __initcall(fn) device_initcall(fn)
>                           ^~~~~~~~~~~~~~~~~~~
>    include/linux/init.h:311:30: note: expanded from macro 'device_initcall'
>    #define device_initcall(fn)             __define_initcall(fn, 6)
>                                            ^~~~~~~~~~~~~~~~~~~~~~~~
>    note: (skipping 8 expansions in backtrace; use -fmacro-backtrace-limit=0 to see all)
>    include/linux/compiler_types.h:75:22: note: expanded from macro '__PASTE'
>    #define __PASTE(a,b) ___PASTE(a,b)
>                         ^
>    include/linux/compiler_types.h:74:23: note: expanded from macro '___PASTE'
>    #define ___PASTE(a,b) a##b
>                          ^
>    <scratch space>:28:1: note: expanded from here
>    rdt_l3_pseudolock__215_569_cat_init6216
>    ^
> >> fs/resctrl2/arch/x86/l3_pseudolock.c:569:1: error: expected ';' after top level declarator
>    include/linux/module.h:88:24: note: expanded from macro 'module_init'
>    #define module_init(x)  __initcall(x);
>                            ^
>    include/linux/init.h:316:24: note: expanded from macro '__initcall'
>    #define __initcall(fn) device_initcall(fn)
>                           ^
>    include/linux/init.h:311:30: note: expanded from macro 'device_initcall'
>    #define device_initcall(fn)             __define_initcall(fn, 6)
>                                            ^
>    note: (skipping 1 expansions in backtrace; use -fmacro-backtrace-limit=0 to see all)
>    include/linux/init.h:280:35: note: expanded from macro '___define_initcall'
>            __unique_initcall(fn, id, __sec, __initcall_id(fn))
>                                             ^
>    include/linux/init.h:209:10: note: expanded from macro '__initcall_id'
>            __PASTE(__KBUILD_MODNAME,                               \
>                    ^
>    <command line>:9:48: note: expanded from macro '__KBUILD_MODNAME'
>    #define __KBUILD_MODNAME kmod_rdt_l2_pseudolock:rdt_l3_pseudolock
>                                                   ^
> >> fs/resctrl2/arch/x86/l3_pseudolock.c:569:1: error: type specifier missing, defaults to 'int'; ISO C99 and later do not support implicit int [-Wimplicit-int]
>    include/linux/module.h:88:24: note: expanded from macro 'module_init'
>    #define module_init(x)  __initcall(x);
>                            ^
>    include/linux/init.h:316:24: note: expanded from macro '__initcall'
>    #define __initcall(fn) device_initcall(fn)
>                           ^
>    include/linux/init.h:311:30: note: expanded from macro 'device_initcall'
>    #define device_initcall(fn)             __define_initcall(fn, 6)
>                                            ^
>    note: (skipping 5 expansions in backtrace; use -fmacro-backtrace-limit=0 to see all)
>    include/linux/compiler_types.h:75:22: note: expanded from macro '__PASTE'
>    #define __PASTE(a,b) ___PASTE(a,b)
>                         ^
>    include/linux/compiler_types.h:74:23: note: expanded from macro '___PASTE'
>    #define ___PASTE(a,b) a##b
>                          ^
>    <scratch space>:15:1: note: expanded from here
>    rdt_l3_pseudolock__215_569_cat_init6
>    ^
> >> fs/resctrl2/arch/x86/l3_pseudolock.c:569:1: error: redefinition of 'rdt_l3_pseudolock__215_569_cat_init6' as different kind of symbol
>    include/linux/module.h:88:24: note: expanded from macro 'module_init'
>    #define module_init(x)  __initcall(x);
>                            ^
>    include/linux/init.h:316:24: note: expanded from macro '__initcall'
>    #define __initcall(fn) device_initcall(fn)
>                           ^
>    include/linux/init.h:311:30: note: expanded from macro 'device_initcall'
>    #define device_initcall(fn)             __define_initcall(fn, 6)
>                                            ^
>    note: (skipping 5 expansions in backtrace; use -fmacro-backtrace-limit=0 to see all)
>    include/linux/compiler_types.h:75:22: note: expanded from macro '__PASTE'
>    #define __PASTE(a,b) ___PASTE(a,b)
>                         ^
>    include/linux/compiler_types.h:74:23: note: expanded from macro '___PASTE'
>    #define ___PASTE(a,b) a##b
>                          ^
>    <scratch space>:15:1: note: expanded from here
>    rdt_l3_pseudolock__215_569_cat_init6
>    ^
>    fs/resctrl2/arch/x86/l3_pseudolock.c:569:1: note: previous definition is here
>    include/linux/module.h:88:24: note: expanded from macro 'module_init'
>    #define module_init(x)  __initcall(x);
>                            ^
>    include/linux/init.h:316:24: note: expanded from macro '__initcall'
>    #define __initcall(fn) device_initcall(fn)
>                           ^
>    include/linux/init.h:311:30: note: expanded from macro 'device_initcall'
>    #define device_initcall(fn)             __define_initcall(fn, 6)
>                                            ^
>    note: (skipping 5 expansions in backtrace; use -fmacro-backtrace-limit=0 to see all)
>    include/linux/compiler_types.h:75:22: note: expanded from macro '__PASTE'
>    #define __PASTE(a,b) ___PASTE(a,b)
>                         ^
>    include/linux/compiler_types.h:74:23: note: expanded from macro '___PASTE'
>    #define ___PASTE(a,b) a##b
>                          ^
>    <scratch space>:15:1: note: expanded from here
>    rdt_l3_pseudolock__215_569_cat_init6
>    ^
> >> fs/resctrl2/arch/x86/l3_pseudolock.c:569:1: error: '__initstub__kmod_rdt_l2_pseudolock' causes a section type conflict with 'init_rootfs'
>    module_init(cat_init);
>    ^
>    include/linux/module.h:88:24: note: expanded from macro 'module_init'
>    #define module_init(x)  __initcall(x);
>                            ^
>    include/linux/init.h:316:24: note: expanded from macro '__initcall'
>    #define __initcall(fn) device_initcall(fn)
>                           ^
>    include/linux/init.h:311:30: note: expanded from macro 'device_initcall'
>    #define device_initcall(fn)             __define_initcall(fn, 6)
>                                            ^
>    note: (skipping 5 expansions in backtrace; use -fmacro-backtrace-limit=0 to see all)
>    include/linux/compiler_types.h:75:22: note: expanded from macro '__PASTE'
>    #define __PASTE(a,b) ___PASTE(a,b)
>                         ^
>    include/linux/compiler_types.h:74:23: note: expanded from macro '___PASTE'
>    #define ___PASTE(a,b) a##b
>                          ^
>    <scratch space>:18:1: note: expanded from here
>    __initstub__kmod_rdt_l2_pseudolock
>    ^
>    include/linux/init.h:154:13: note: declared here
>    void __init init_rootfs(void);
>                ^
>    2 warnings and 11 errors generated.

This only happens with LTO, which is clang specific, because
__KBUILD_MODNAME has a colon in it, which makes the indentifier
generated by __initcall_id() invalid, as I can see from the preprocessed
source:

int __attribute__((__section__(".init.text"))) __attribute__((__cold__)) __initstub__kmod_rdt_l2_pseudolock:rdt_l3_pseudolock__215_569_cat_init6(void);
int __attribute__((__section__(".init.text"))) __attribute__((__cold__)) __initstub__kmod_rdt_l2_pseudolock:rdt_l3_pseudolock__215_569_cat_init6(void) { return cat_init(); }

Seems like a copy and paste fail? This fixes it for me:

diff --git a/fs/resctrl2/arch/x86/Makefile b/fs/resctrl2/arch/x86/Makefile
index f9e089d047a9..fc1dc74ad61b 100644
--- a/fs/resctrl2/arch/x86/Makefile
+++ b/fs/resctrl2/arch/x86/Makefile
@@ -35,6 +35,6 @@ CFLAGS_l2_pseudolock.o 			+= -DCACHE_LEVEL=2 -DPSEUDO_LOCK
 rdt_l3_pseudolock-y			:= l3_pseudolock.o pseudo_lock.o
 obj-$(CONFIG_X86_RDT_L3_PSEUDOLOCK)	+= rdt_l3_pseudolock.o
 rdt_l2_pseudolock-y			:= l3_pseudolock.o pseudo_lock.o
-obj-$(CONFIG_X86_RDT_L3_PSEUDOLOCK)	+= rdt_l2_pseudolock.o
+obj-$(CONFIG_X86_RDT_L2_PSEUDOLOCK)	+= rdt_l2_pseudolock.o
 
 CFLAGS_pseudo_lock.o = -I$(src) -DPSEUDO_LOCK

Cheers,
Nathan
