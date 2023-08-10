Return-Path: <linux-ia64-owner@vger.kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from vger.kernel.org (vger.kernel.org [23.128.96.18])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D07E3C001E0
	for <linux-ia64@archiver.kernel.org>; Thu, 10 Aug 2023 14:35:17 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S235464AbjHJOfQ (ORCPT <rfc822;linux-ia64@archiver.kernel.org>);
        Thu, 10 Aug 2023 10:35:16 -0400
Received: from lindbergh.monkeyblade.net ([23.128.96.19]:42358 "EHLO
        lindbergh.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S235637AbjHJOfP (ORCPT
        <rfc822;linux-ia64@vger.kernel.org>); Thu, 10 Aug 2023 10:35:15 -0400
Received: from dfw.source.kernel.org (dfw.source.kernel.org [IPv6:2604:1380:4641:c500::1])
        by lindbergh.monkeyblade.net (Postfix) with ESMTPS id C00C62698
        for <linux-ia64@vger.kernel.org>; Thu, 10 Aug 2023 07:35:14 -0700 (PDT)
Received: from smtp.kernel.org (relay.kernel.org [52.25.139.140])
        (using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
         key-exchange X25519 server-signature RSA-PSS (2048 bits))
        (No client certificate requested)
        by dfw.source.kernel.org (Postfix) with ESMTPS id 449176202A
        for <linux-ia64@vger.kernel.org>; Thu, 10 Aug 2023 14:35:14 +0000 (UTC)
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 3B61CC433C7;
        Thu, 10 Aug 2023 14:35:13 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
        s=k20201202; t=1691678113;
        bh=l7iX2EFXiiKalApDOgrMA9KciL+YR2kWW6FuOaN5oXo=;
        h=Date:From:To:Cc:Subject:References:In-Reply-To:From;
        b=I62Nd4+MWtex1Kqp9IwKczgKaZxjLl4uwfpI+9RKlMS9gah1cJZaGCNLwzGR1rEOY
         RFsjtWDXbanVmYxezCl+eTUt1dSHDtGXgfM13CcBaaR2dnSCorr+o7ka9/b5WSdhRE
         XRV0ry1YbnyoJlU5C8tlCDvEJQrk18j8CKrDzBrr2iGYf73rnccTlWlJ91LLNwRgrv
         F8Lsi3x7I4xTd79G1wXEeLKib48kiFHjuL6EhAdGQ6k5bE2cFjXiFkg/N3roY03tNC
         8pwapyCbF9piGqDPakbkcBZfBfIZ189zlA8DmBQC6L+0o4Mn9SorQNvZGR3aBti1BH
         5vK8/N8OlKIwA==
Date:   Thu, 10 Aug 2023 07:35:11 -0700
From:   Nathan Chancellor <nathan@kernel.org>
To:     Yujie Liu <yujie.liu@intel.com>
Cc:     Nick Desaulniers <ndesaulniers@google.com>,
        Tony Luck <tony.luck@intel.com>, llvm@lists.linux.dev,
        oe-kbuild-all@lists.linux.dev, linux-ia64@vger.kernel.org,
        kernel test robot <lkp@intel.com>
Subject: Re: [aegl:resctrl2_v65rc4 2/2]
 fs/resctrl2/arch/x86/l3_pseudolock.c:569:1: error: expected ';' after top
 level declarator
Message-ID: <20230810143511.GB1549244@dev-arch.thelio-3990X>
References: <202308040650.ayL6ExhZ-lkp@intel.com>
 <ZNSFUHra6FTSxFLF@yujie-X299>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <ZNSFUHra6FTSxFLF@yujie-X299>
Precedence: bulk
List-ID: <linux-ia64.vger.kernel.org>
X-Mailing-List: linux-ia64@vger.kernel.org

Hi Yujie,

On Thu, Aug 10, 2023 at 02:36:00PM +0800, Yujie Liu wrote:
> Hi Nathan, Hi Nick,
> 
> Could you kindly help to take a look at this report?
> 
> Quote Tony's comment:
> 
> > It seems that some/all of the combination of CLANG, ARCH=i386, and
> > building with CONFIG_XXX=y rather than CONFIG_XXX=m makes clang freak
> > out.
> > GCC seems able to build the files in fs/resctrl2/arch/x86/ as either
> > modules or built-in, x86_64 or i386 without problems.
> 
> We re-tested this case and got the same result as Tony's. GCC can build
> this without problems, while various versions of clang (clang
> 17/16/15/14) throw this error. Could you help do a quick check to see if
> necessary to track an issue? Thanks.

I'll do my best to take a look at this either today/tomorrow or early
next week. We're dealing with some fallout from the SRSO mitigations, so
that has been priority 0 at the moment.

Cheers,
Nathan

> On Fri, Aug 04, 2023 at 06:45:45AM +0800, kernel test robot wrote:
> > tree:   https://git.kernel.org/pub/scm/linux/kernel/git/aegl/linux.git resctrl2_v65rc4
> > head:   36621209814f9810feed9af60d278a198847c117
> > commit: 36621209814f9810feed9af60d278a198847c117 [2/2] resctrl2: Arch x86 modules for most of the legacy control/monitor functions
> > config: i386-randconfig-r032-20230804 (https://download.01.org/0day-ci/archive/20230804/202308040650.ayL6ExhZ-lkp@intel.com/config)
> > compiler: clang version 16.0.4 (https://github.com/llvm/llvm-project.git ae42196bc493ffe877a7e3dff8be32035dea4d07)
> > reproduce: (https://download.01.org/0day-ci/archive/20230804/202308040650.ayL6ExhZ-lkp@intel.com/reproduce)
> > 
> > If you fix the issue in a separate patch/commit (i.e. not just a new version of
> > the same patch/commit), kindly add following tags
> > | Reported-by: kernel test robot <lkp@intel.com>
> > | Closes: https://lore.kernel.org/oe-kbuild-all/202308040650.ayL6ExhZ-lkp@intel.com/
> > 
> > All errors (new ones prefixed by >>):
> > 
> >    fs/resctrl2/arch/x86/l3_pseudolock.c:569:1: warning: '__cold__' attribute only applies to functions [-Wignored-attributes]
> >    module_init(cat_init);
> >    ^
> >    include/linux/module.h:88:24: note: expanded from macro 'module_init'
> >    #define module_init(x)  __initcall(x);
> >                            ^
> >    include/linux/init.h:316:24: note: expanded from macro '__initcall'
> >    #define __initcall(fn) device_initcall(fn)
> >                           ^
> >    include/linux/init.h:311:30: note: expanded from macro 'device_initcall'
> >    #define device_initcall(fn)             __define_initcall(fn, 6)
> >                                            ^
> >    note: (skipping 4 expansions in backtrace; use -fmacro-backtrace-limit=0 to see all)
> >    include/linux/init.h:243:6: note: expanded from macro '__define_initcall_stub'
> >            int __init __stub(void);                                \
> >                ^
> >    include/linux/init.h:52:41: note: expanded from macro '__init'
> >    #define __init          __section(".init.text") __cold  __latent_entropy __noinitretpoline
> >                                                    ^
> >    include/linux/compiler_types.h:104:34: note: expanded from macro '__cold'
> >    #define __cold                          __attribute__((__cold__))
> >                                                           ^
> > >> fs/resctrl2/arch/x86/l3_pseudolock.c:569:1: error: expected ';' after top level declarator
> >    include/linux/module.h:88:24: note: expanded from macro 'module_init'
> >    #define module_init(x)  __initcall(x);
> >                            ^
> >    include/linux/init.h:316:24: note: expanded from macro '__initcall'
> >    #define __initcall(fn) device_initcall(fn)
> >                           ^
> >    include/linux/init.h:311:30: note: expanded from macro 'device_initcall'
> >    #define device_initcall(fn)             __define_initcall(fn, 6)
> >                                            ^
> >    note: (skipping 1 expansions in backtrace; use -fmacro-backtrace-limit=0 to see all)
> >    include/linux/init.h:280:35: note: expanded from macro '___define_initcall'
> >            __unique_initcall(fn, id, __sec, __initcall_id(fn))
> >                                             ^
> >    include/linux/init.h:209:10: note: expanded from macro '__initcall_id'
> >            __PASTE(__KBUILD_MODNAME,                               \
> >                    ^
> >    <command line>:9:48: note: expanded from macro '__KBUILD_MODNAME'
> >    #define __KBUILD_MODNAME kmod_rdt_l2_pseudolock:rdt_l3_pseudolock
> >                                                   ^
> > >> fs/resctrl2/arch/x86/l3_pseudolock.c:569:1: error: type specifier missing, defaults to 'int'; ISO C99 and later do not support implicit int [-Wimplicit-int]
> >    include/linux/module.h:88:24: note: expanded from macro 'module_init'
> >    #define module_init(x)  __initcall(x);
> >                            ^
> >    include/linux/init.h:316:24: note: expanded from macro '__initcall'
> >    #define __initcall(fn) device_initcall(fn)
> >                           ^
> >    include/linux/init.h:311:30: note: expanded from macro 'device_initcall'
> >    #define device_initcall(fn)             __define_initcall(fn, 6)
> >                                            ^
> >    note: (skipping 5 expansions in backtrace; use -fmacro-backtrace-limit=0 to see all)
> >    include/linux/compiler_types.h:75:22: note: expanded from macro '__PASTE'
> >    #define __PASTE(a,b) ___PASTE(a,b)
> >                         ^
> >    include/linux/compiler_types.h:74:23: note: expanded from macro '___PASTE'
> >    #define ___PASTE(a,b) a##b
> >                          ^
> >    <scratch space>:15:1: note: expanded from here
> >    rdt_l3_pseudolock__215_569_cat_init6
> >    ^
> >    fs/resctrl2/arch/x86/l3_pseudolock.c:569:1: warning: '__cold__' attribute only applies to functions [-Wignored-attributes]
> >    include/linux/module.h:88:24: note: expanded from macro 'module_init'
> >    #define module_init(x)  __initcall(x);
> >                            ^
> >    include/linux/init.h:316:24: note: expanded from macro '__initcall'
> >    #define __initcall(fn) device_initcall(fn)
> >                           ^
> >    include/linux/init.h:311:30: note: expanded from macro 'device_initcall'
> >    #define device_initcall(fn)             __define_initcall(fn, 6)
> >                                            ^
> >    note: (skipping 4 expansions in backtrace; use -fmacro-backtrace-limit=0 to see all)
> >    include/linux/init.h:244:6: note: expanded from macro '__define_initcall_stub'
> >            int __init __stub(void)                                 \
> >                ^
> >    include/linux/init.h:52:41: note: expanded from macro '__init'
> >    #define __init          __section(".init.text") __cold  __latent_entropy __noinitretpoline
> >                                                    ^
> >    include/linux/compiler_types.h:104:34: note: expanded from macro '__cold'
> >    #define __cold                          __attribute__((__cold__))
> >                                                           ^
> > >> fs/resctrl2/arch/x86/l3_pseudolock.c:569:1: error: expected ';' after top level declarator
> >    include/linux/module.h:88:24: note: expanded from macro 'module_init'
> >    #define module_init(x)  __initcall(x);
> >                            ^
> >    include/linux/init.h:316:24: note: expanded from macro '__initcall'
> >    #define __initcall(fn) device_initcall(fn)
> >                           ^
> >    include/linux/init.h:311:30: note: expanded from macro 'device_initcall'
> >    #define device_initcall(fn)             __define_initcall(fn, 6)
> >                                            ^
> >    note: (skipping 1 expansions in backtrace; use -fmacro-backtrace-limit=0 to see all)
> >    include/linux/init.h:280:35: note: expanded from macro '___define_initcall'
> >            __unique_initcall(fn, id, __sec, __initcall_id(fn))
> >                                             ^
> >    include/linux/init.h:209:10: note: expanded from macro '__initcall_id'
> >            __PASTE(__KBUILD_MODNAME,                               \
> >                    ^
> >    <command line>:9:48: note: expanded from macro '__KBUILD_MODNAME'
> >    #define __KBUILD_MODNAME kmod_rdt_l2_pseudolock:rdt_l3_pseudolock
> >                                                   ^
> > >> fs/resctrl2/arch/x86/l3_pseudolock.c:569:1: error: type specifier missing, defaults to 'int'; ISO C99 and later do not support implicit int [-Wimplicit-int]
> >    include/linux/module.h:88:24: note: expanded from macro 'module_init'
> >    #define module_init(x)  __initcall(x);
> >                            ^
> >    include/linux/init.h:316:24: note: expanded from macro '__initcall'
> >    #define __initcall(fn) device_initcall(fn)
> >                           ^
> >    include/linux/init.h:311:30: note: expanded from macro 'device_initcall'
> >    #define device_initcall(fn)             __define_initcall(fn, 6)
> >                                            ^
> >    note: (skipping 5 expansions in backtrace; use -fmacro-backtrace-limit=0 to see all)
> >    include/linux/compiler_types.h:75:22: note: expanded from macro '__PASTE'
> >    #define __PASTE(a,b) ___PASTE(a,b)
> >                         ^
> >    include/linux/compiler_types.h:74:23: note: expanded from macro '___PASTE'
> >    #define ___PASTE(a,b) a##b
> >                          ^
> >    <scratch space>:15:1: note: expanded from here
> >    rdt_l3_pseudolock__215_569_cat_init6
> >    ^
> > >> fs/resctrl2/arch/x86/l3_pseudolock.c:569:1: error: expected ';' after top level declarator
> >    include/linux/module.h:88:24: note: expanded from macro 'module_init'
> >    #define module_init(x)  __initcall(x);
> >                            ^
> >    include/linux/init.h:316:24: note: expanded from macro '__initcall'
> >    #define __initcall(fn) device_initcall(fn)
> >                           ^
> >    include/linux/init.h:311:30: note: expanded from macro 'device_initcall'
> >    #define device_initcall(fn)             __define_initcall(fn, 6)
> >                                            ^
> >    note: (skipping 1 expansions in backtrace; use -fmacro-backtrace-limit=0 to see all)
> >    include/linux/init.h:280:35: note: expanded from macro '___define_initcall'
> >            __unique_initcall(fn, id, __sec, __initcall_id(fn))
> >                                             ^
> >    include/linux/init.h:209:10: note: expanded from macro '__initcall_id'
> >            __PASTE(__KBUILD_MODNAME,                               \
> >                    ^
> >    <command line>:9:48: note: expanded from macro '__KBUILD_MODNAME'
> >    #define __KBUILD_MODNAME kmod_rdt_l2_pseudolock:rdt_l3_pseudolock
> >                                                   ^
> > >> fs/resctrl2/arch/x86/l3_pseudolock.c:569:1: error: type specifier missing, defaults to 'int'; ISO C99 and later do not support implicit int [-Wimplicit-int]
> >    include/linux/module.h:88:24: note: expanded from macro 'module_init'
> >    #define module_init(x)  __initcall(x);
> >                            ^
> >    include/linux/init.h:316:24: note: expanded from macro '__initcall'
> >    #define __initcall(fn) device_initcall(fn)
> >                           ^
> >    include/linux/init.h:311:30: note: expanded from macro 'device_initcall'
> >    #define device_initcall(fn)             __define_initcall(fn, 6)
> >                                            ^
> >    note: (skipping 8 expansions in backtrace; use -fmacro-backtrace-limit=0 to see all)
> >    include/linux/compiler_types.h:75:22: note: expanded from macro '__PASTE'
> >    #define __PASTE(a,b) ___PASTE(a,b)
> >                         ^
> >    include/linux/compiler_types.h:74:23: note: expanded from macro '___PASTE'
> >    #define ___PASTE(a,b) a##b
> >                          ^
> >    <scratch space>:28:1: note: expanded from here
> >    rdt_l3_pseudolock__215_569_cat_init6216
> >    ^
> > >> fs/resctrl2/arch/x86/l3_pseudolock.c:569:1: error: incompatible pointer to integer conversion initializing 'int' with an expression of type 'void *' [-Wint-conversion]
> >    module_init(cat_init);
> >    ^~~~~~~~~~~~~~~~~~~~~
> >    include/linux/module.h:88:24: note: expanded from macro 'module_init'
> >    #define module_init(x)  __initcall(x);
> >                            ^~~~~~~~~~~~~
> >    include/linux/init.h:316:24: note: expanded from macro '__initcall'
> >    #define __initcall(fn) device_initcall(fn)
> >                           ^~~~~~~~~~~~~~~~~~~
> >    include/linux/init.h:311:30: note: expanded from macro 'device_initcall'
> >    #define device_initcall(fn)             __define_initcall(fn, 6)
> >                                            ^~~~~~~~~~~~~~~~~~~~~~~~
> >    note: (skipping 8 expansions in backtrace; use -fmacro-backtrace-limit=0 to see all)
> >    include/linux/compiler_types.h:75:22: note: expanded from macro '__PASTE'
> >    #define __PASTE(a,b) ___PASTE(a,b)
> >                         ^
> >    include/linux/compiler_types.h:74:23: note: expanded from macro '___PASTE'
> >    #define ___PASTE(a,b) a##b
> >                          ^
> >    <scratch space>:28:1: note: expanded from here
> >    rdt_l3_pseudolock__215_569_cat_init6216
> >    ^
> > >> fs/resctrl2/arch/x86/l3_pseudolock.c:569:1: error: expected ';' after top level declarator
> >    include/linux/module.h:88:24: note: expanded from macro 'module_init'
> >    #define module_init(x)  __initcall(x);
> >                            ^
> >    include/linux/init.h:316:24: note: expanded from macro '__initcall'
> >    #define __initcall(fn) device_initcall(fn)
> >                           ^
> >    include/linux/init.h:311:30: note: expanded from macro 'device_initcall'
> >    #define device_initcall(fn)             __define_initcall(fn, 6)
> >                                            ^
> >    note: (skipping 1 expansions in backtrace; use -fmacro-backtrace-limit=0 to see all)
> >    include/linux/init.h:280:35: note: expanded from macro '___define_initcall'
> >            __unique_initcall(fn, id, __sec, __initcall_id(fn))
> >                                             ^
> >    include/linux/init.h:209:10: note: expanded from macro '__initcall_id'
> >            __PASTE(__KBUILD_MODNAME,                               \
> >                    ^
> >    <command line>:9:48: note: expanded from macro '__KBUILD_MODNAME'
> >    #define __KBUILD_MODNAME kmod_rdt_l2_pseudolock:rdt_l3_pseudolock
> >                                                   ^
> > >> fs/resctrl2/arch/x86/l3_pseudolock.c:569:1: error: type specifier missing, defaults to 'int'; ISO C99 and later do not support implicit int [-Wimplicit-int]
> >    include/linux/module.h:88:24: note: expanded from macro 'module_init'
> >    #define module_init(x)  __initcall(x);
> >                            ^
> >    include/linux/init.h:316:24: note: expanded from macro '__initcall'
> >    #define __initcall(fn) device_initcall(fn)
> >                           ^
> >    include/linux/init.h:311:30: note: expanded from macro 'device_initcall'
> >    #define device_initcall(fn)             __define_initcall(fn, 6)
> >                                            ^
> >    note: (skipping 5 expansions in backtrace; use -fmacro-backtrace-limit=0 to see all)
> >    include/linux/compiler_types.h:75:22: note: expanded from macro '__PASTE'
> >    #define __PASTE(a,b) ___PASTE(a,b)
> >                         ^
> >    include/linux/compiler_types.h:74:23: note: expanded from macro '___PASTE'
> >    #define ___PASTE(a,b) a##b
> >                          ^
> >    <scratch space>:15:1: note: expanded from here
> >    rdt_l3_pseudolock__215_569_cat_init6
> >    ^
> > >> fs/resctrl2/arch/x86/l3_pseudolock.c:569:1: error: redefinition of 'rdt_l3_pseudolock__215_569_cat_init6' as different kind of symbol
> >    include/linux/module.h:88:24: note: expanded from macro 'module_init'
> >    #define module_init(x)  __initcall(x);
> >                            ^
> >    include/linux/init.h:316:24: note: expanded from macro '__initcall'
> >    #define __initcall(fn) device_initcall(fn)
> >                           ^
> >    include/linux/init.h:311:30: note: expanded from macro 'device_initcall'
> >    #define device_initcall(fn)             __define_initcall(fn, 6)
> >                                            ^
> >    note: (skipping 5 expansions in backtrace; use -fmacro-backtrace-limit=0 to see all)
> >    include/linux/compiler_types.h:75:22: note: expanded from macro '__PASTE'
> >    #define __PASTE(a,b) ___PASTE(a,b)
> >                         ^
> >    include/linux/compiler_types.h:74:23: note: expanded from macro '___PASTE'
> >    #define ___PASTE(a,b) a##b
> >                          ^
> >    <scratch space>:15:1: note: expanded from here
> >    rdt_l3_pseudolock__215_569_cat_init6
> >    ^
> >    fs/resctrl2/arch/x86/l3_pseudolock.c:569:1: note: previous definition is here
> >    include/linux/module.h:88:24: note: expanded from macro 'module_init'
> >    #define module_init(x)  __initcall(x);
> >                            ^
> >    include/linux/init.h:316:24: note: expanded from macro '__initcall'
> >    #define __initcall(fn) device_initcall(fn)
> >                           ^
> >    include/linux/init.h:311:30: note: expanded from macro 'device_initcall'
> >    #define device_initcall(fn)             __define_initcall(fn, 6)
> >                                            ^
> >    note: (skipping 5 expansions in backtrace; use -fmacro-backtrace-limit=0 to see all)
> >    include/linux/compiler_types.h:75:22: note: expanded from macro '__PASTE'
> >    #define __PASTE(a,b) ___PASTE(a,b)
> >                         ^
> >    include/linux/compiler_types.h:74:23: note: expanded from macro '___PASTE'
> >    #define ___PASTE(a,b) a##b
> >                          ^
> >    <scratch space>:15:1: note: expanded from here
> >    rdt_l3_pseudolock__215_569_cat_init6
> >    ^
> > >> fs/resctrl2/arch/x86/l3_pseudolock.c:569:1: error: '__initstub__kmod_rdt_l2_pseudolock' causes a section type conflict with 'init_rootfs'
> >    module_init(cat_init);
> >    ^
> >    include/linux/module.h:88:24: note: expanded from macro 'module_init'
> >    #define module_init(x)  __initcall(x);
> >                            ^
> >    include/linux/init.h:316:24: note: expanded from macro '__initcall'
> >    #define __initcall(fn) device_initcall(fn)
> >                           ^
> >    include/linux/init.h:311:30: note: expanded from macro 'device_initcall'
> >    #define device_initcall(fn)             __define_initcall(fn, 6)
> >                                            ^
> >    note: (skipping 5 expansions in backtrace; use -fmacro-backtrace-limit=0 to see all)
> >    include/linux/compiler_types.h:75:22: note: expanded from macro '__PASTE'
> >    #define __PASTE(a,b) ___PASTE(a,b)
> >                         ^
> >    include/linux/compiler_types.h:74:23: note: expanded from macro '___PASTE'
> >    #define ___PASTE(a,b) a##b
> >                          ^
> >    <scratch space>:18:1: note: expanded from here
> >    __initstub__kmod_rdt_l2_pseudolock
> >    ^
> >    include/linux/init.h:154:13: note: declared here
> >    void __init init_rootfs(void);
> >                ^
> >    2 warnings and 11 errors generated.
> > 
> > 
> > vim +569 fs/resctrl2/arch/x86/l3_pseudolock.c
> > 
> >    568	
> >  > 569	module_init(cat_init);
> >    570	module_exit(cat_cleanup);
> >    571	
> > 
> > -- 
> > 0-DAY CI Kernel Test Service
> > https://github.com/intel/lkp-tests/wiki
> > 
> 
