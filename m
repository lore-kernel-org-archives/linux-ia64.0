Return-Path: <linux-ia64-owner@vger.kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from vger.kernel.org (vger.kernel.org [23.128.96.18])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D7395C001DB
	for <linux-ia64@archiver.kernel.org>; Thu, 10 Aug 2023 06:40:10 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S231991AbjHJGkJ (ORCPT <rfc822;linux-ia64@archiver.kernel.org>);
        Thu, 10 Aug 2023 02:40:09 -0400
Received: from lindbergh.monkeyblade.net ([23.128.96.19]:36464 "EHLO
        lindbergh.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S231303AbjHJGkJ (ORCPT
        <rfc822;linux-ia64@vger.kernel.org>); Thu, 10 Aug 2023 02:40:09 -0400
Received: from mgamail.intel.com (mgamail.intel.com [134.134.136.24])
        by lindbergh.monkeyblade.net (Postfix) with ESMTPS id DDFE8E4B
        for <linux-ia64@vger.kernel.org>; Wed,  9 Aug 2023 23:40:07 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple;
  d=intel.com; i=@intel.com; q=dns/txt; s=Intel;
  t=1691649607; x=1723185607;
  h=date:from:to:cc:subject:message-id:references:
   in-reply-to:mime-version;
  bh=64nfHyTyY/gGfhpxsvyw1u/hWAbT9w9x9kn69mNL3Ac=;
  b=O4AxfEjo4xFwwFHAAaHlHE9zUpHD2P1uql61F3ROJ/ZYGZM2rDKsHsPn
   4TPd6oUh7baX8Ickn8dYObDGiQXzgr/TmZVhDiXqlPgVf8805+w1fioRv
   tJdD117NK26hNmfX4f9ACC261JRMEfciQAtdnRXFR73xJOLaxwglCbgWZ
   Gl3XiWRUT7//m/zxnOS+e0jbxHqJrOk898vGAdkPC6jfnMYtUj3H/HO6l
   i8+PYrvMg43FB+R5vlcU6fJ28AfUR5N/4vultogxJaokuCYAtsTa8qhoj
   M/oWRqx+YOroqSpoSckoWXEIUyamP3mmPrDcEpQZYMdC90jFnKwpN3kuW
   g==;
X-IronPort-AV: E=McAfee;i="6600,9927,10797"; a="374089439"
X-IronPort-AV: E=Sophos;i="6.01,161,1684825200"; 
   d="scan'208";a="374089439"
Received: from orsmga001.jf.intel.com ([10.7.209.18])
  by orsmga102.jf.intel.com with ESMTP/TLS/ECDHE-RSA-AES256-GCM-SHA384; 09 Aug 2023 23:40:07 -0700
X-ExtLoop1: 1
X-IronPort-AV: E=McAfee;i="6600,9927,10797"; a="767159929"
X-IronPort-AV: E=Sophos;i="6.01,161,1684825200"; 
   d="scan'208";a="767159929"
Received: from fmsmsx601.amr.corp.intel.com ([10.18.126.81])
  by orsmga001.jf.intel.com with ESMTP; 09 Aug 2023 23:40:07 -0700
Received: from fmsmsx610.amr.corp.intel.com (10.18.126.90) by
 fmsmsx601.amr.corp.intel.com (10.18.126.81) with Microsoft SMTP Server
 (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_128_GCM_SHA256) id
 15.1.2507.27; Wed, 9 Aug 2023 23:40:06 -0700
Received: from FMSEDG603.ED.cps.intel.com (10.1.192.133) by
 fmsmsx610.amr.corp.intel.com (10.18.126.90) with Microsoft SMTP Server
 (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_128_GCM_SHA256) id
 15.1.2507.27 via Frontend Transport; Wed, 9 Aug 2023 23:40:06 -0700
Received: from NAM10-BN7-obe.outbound.protection.outlook.com (104.47.70.102)
 by edgegateway.intel.com (192.55.55.68) with Microsoft SMTP Server
 (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.1.2507.27; Wed, 9 Aug 2023 23:40:06 -0700
ARC-Seal: i=1; a=rsa-sha256; s=arcselector9901; d=microsoft.com; cv=none;
 b=Q1AH6Dhx47lxx+GI0X7qmQMD11ptSCHEF4z3ngGlnj56EHZJGa7ebmCbfFKT2qsVVN4YVkup9jipciTtxN4Z0pkxljeFfJV1uDS7wP3gEcXXlPHCyxXjSRCBt0DWSw/U/OhKE4tuNxKAuFFOnHDXii7jzDH6vLlolDPG1Y4xF0VzwycInphh69uhP24CKihvXPFUWlpWrcb9cDPgI7Jd1dANVxSreNaIlJ5Ideedq8JdPdm8/qc0OzKimYWQ9+gGU5a5IWAQVuHH2l5jyyO9RZl0kI5TcDFh7CC1K7dqZLwFZZCaMIRHEvFXmqTKXqIte8NUbeLLemtHhdRlEWTyrg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=microsoft.com;
 s=arcselector9901;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-AntiSpam-MessageData-ChunkCount:X-MS-Exchange-AntiSpam-MessageData-0:X-MS-Exchange-AntiSpam-MessageData-1;
 bh=/3H93lpvqmDSgxgyiRnlZf4Rr1OLhv0B+3WvsAYlif4=;
 b=cy3wQQwV+gHz4HpMAeFhFL4IaH0d30WPQDv5LXyPgQltLZOZTrzZO65OkTFQPH0bWbzYOKKrjnehhk03BO7JHlhB8CgozXIIohmhxPqn3nqT49MxJ+0Lj8V96ZDXthUY3FeS8PHx22gcvlrJmBbJSOZS2rBbMsNULtPQ431K27oVIATxvm3o+TMYg5t57chNl+Zte7MIX9JTqOjoKRqiXQsAqh1Tl+BMZcqCHy8RBtbOZOAvvqKQhLREwsGIYSg/t58csrzR9JUL5g6D/tEhYCYqQ2h4bzjYG3S3lPQacvhNgnvu2i6ShsLcbdoEnYm9i4S2+8BLcIdEaai2R+4NhQ==
ARC-Authentication-Results: i=1; mx.microsoft.com 1; spf=pass
 smtp.mailfrom=intel.com; dmarc=pass action=none header.from=intel.com;
 dkim=pass header.d=intel.com; arc=none
Authentication-Results: dkim=none (message not signed)
 header.d=none;dmarc=none action=none header.from=intel.com;
Received: from CY5PR11MB6392.namprd11.prod.outlook.com (2603:10b6:930:37::15)
 by BL1PR11MB5544.namprd11.prod.outlook.com (2603:10b6:208:314::19) with
 Microsoft SMTP Server (version=TLS1_2,
 cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id 15.20.6652.30; Thu, 10 Aug
 2023 06:40:04 +0000
Received: from CY5PR11MB6392.namprd11.prod.outlook.com
 ([fe80::c407:a2ef:2fde:f6d1]) by CY5PR11MB6392.namprd11.prod.outlook.com
 ([fe80::c407:a2ef:2fde:f6d1%4]) with mapi id 15.20.6652.029; Thu, 10 Aug 2023
 06:40:04 +0000
Date:   Thu, 10 Aug 2023 14:36:00 +0800
From:   Yujie Liu <yujie.liu@intel.com>
To:     Nathan Chancellor <nathan@kernel.org>,
        Nick Desaulniers <ndesaulniers@google.com>
CC:     Tony Luck <tony.luck@intel.com>, <llvm@lists.linux.dev>,
        <oe-kbuild-all@lists.linux.dev>, <linux-ia64@vger.kernel.org>,
        "kernel test robot" <lkp@intel.com>
Subject: Re: [aegl:resctrl2_v65rc4 2/2]
 fs/resctrl2/arch/x86/l3_pseudolock.c:569:1: error: expected ';' after top
 level declarator
Message-ID: <ZNSFUHra6FTSxFLF@yujie-X299>
References: <202308040650.ayL6ExhZ-lkp@intel.com>
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
In-Reply-To: <202308040650.ayL6ExhZ-lkp@intel.com>
X-ClientProxiedBy: SI1PR02CA0050.apcprd02.prod.outlook.com
 (2603:1096:4:1f5::12) To CY5PR11MB6392.namprd11.prod.outlook.com
 (2603:10b6:930:37::15)
MIME-Version: 1.0
X-MS-PublicTrafficType: Email
X-MS-TrafficTypeDiagnostic: CY5PR11MB6392:EE_|BL1PR11MB5544:EE_
X-MS-Office365-Filtering-Correlation-Id: a06d5b7c-e0e6-4261-5317-08db996ca0b9
X-LD-Processed: 46c98d88-e344-4ed4-8496-4ed7712e255d,ExtAddr
X-MS-Exchange-SenderADCheck: 1
X-MS-Exchange-AntiSpam-Relay: 0
X-Microsoft-Antispam: BCL:0;
X-Microsoft-Antispam-Message-Info: U1duqV3ICnVKjAval5JvrLuj5/hS5r6g286W8b/e0DBIzStpUqQdDvQjh7j5FWYz/TlsfrxgOofMK53FgJWyc6lF0lSQNYHZ0IZx1WwMPB1VUd5mlRArnLq+fCqWUj3N6wjoyZ36Xl4Jb+doO1xHUVCITqgkEIr8wJHMIL2neplE4PasfRwWbhg8bnugCu4u98gxuYBQpvlPJ1baVVcdO2zJ1tOt1voq8In37mNfC4Hi/36JAgz1P6F/XEO2nbXFPsdX7uxnrVEct8aoMZCh/6Oskas5apsO8B4M+MJDlB/TKlgKBPH/4dkZlDYkkdpTP2STmns5vhhfpYAq1Co06qiJMd0igBD2GNp3roCg0leRHqz3QbpU7OyhGDEmjXfC/Adk0XrqZbB7XEvtEkA0e51stWr3JvM4+pCjO3K+Mo8vdx8yZ5ow/oEPhQmWaFlbJZhCzncLFrT/G2cSbYWmAgqS0lW9Ln6z/hrci/4hk30BABOjUOK70xc0Xcw6HP5w0y+UqIbKl9UhjKaqsIZJ0C7/uit0MmUPWI7nrxlWyUBTjripWWoFsMegM/WWxrOPmj2xI7kIv19ms9gCGHX/0pn5FBHwXR2a+JRKlu+vPqaD4oT4tRwkztrOB8GtoHdG4GkLCgaucXakBrfujeiK6g==
X-Forefront-Antispam-Report: CIP:255.255.255.255;CTRY:;LANG:en;SCL:1;SRV:;IPV:NLI;SFV:NSPM;H:CY5PR11MB6392.namprd11.prod.outlook.com;PTR:;CAT:NONE;SFS:(13230028)(7916004)(396003)(136003)(39860400002)(366004)(346002)(376002)(451199021)(186006)(1800799006)(6666004)(478600001)(110136005)(66556008)(66946007)(6506007)(107886003)(26005)(54906003)(66476007)(6512007)(6486002)(9686003)(4326008)(966005)(30864003)(316002)(2906002)(41300700001)(33716001)(44832011)(82960400001)(8676002)(5660300002)(38100700002)(86362001)(8936002)(83380400001)(21314003);DIR:OUT;SFP:1102;
X-MS-Exchange-AntiSpam-MessageData-ChunkCount: 1
X-MS-Exchange-AntiSpam-MessageData-0: =?us-ascii?Q?d4nO8FxrKMB6HftNB5tDrFzs4GJNVnC3Ez+67aV9QxypCQavK3IDLtUAlAwY?=
 =?us-ascii?Q?KnPoddfnPSNL67aDFJapo7Q1J8yaKBbPfDicswQVlAWeOLbQNurCGgF9+u2h?=
 =?us-ascii?Q?lvlWYYbyvQGhy8WC+tpVEUju29cf6v4Hhbk8ScG1F1ZSpOZjn34jKpUWPL7x?=
 =?us-ascii?Q?IsOksvcJAwLw9ZIN2/zMdd/I5IME1rJ7+5HtcCvlJfRPlBHIPwywZM6aRJIR?=
 =?us-ascii?Q?OOUjzNY1sHnpzPJePIf3OZX5YOI8Eu16WwhK9rMYJsFoohLNjOF4AC8+1cHf?=
 =?us-ascii?Q?b4696HZ8fXvoCyUPvx0HWyEK2EV8nRK9Nwyp96c97TS2nNYxGHq4/2KiEq8v?=
 =?us-ascii?Q?EwAAxzS92joTdazCQYwlzxSKhVKww+Kc0TnH4yBKxB6HI1efukRMxhRztMF9?=
 =?us-ascii?Q?uj6LfR+yHr5QHRxFOVVNpg5CvYrU84M7gT66KXcvSKaqDUpYlqtloby7yOhC?=
 =?us-ascii?Q?aNX6DmHJRCG4ZbDX7ka7EDCO300fTEugSa+KYTfRnzAlGgfPSI/ERRGowEuB?=
 =?us-ascii?Q?UIhb1qS+/JxDC1N1InvTaxO+qWkjpYHNF4cbk+5Wl3Rz9Td71FE+wiiLPzLB?=
 =?us-ascii?Q?E1Y59LdJAdDz06UaS9xdTJNIcSPC7DF5IRBfUl7tXSIGrJbhCsRu8Og0zf8k?=
 =?us-ascii?Q?euPmjAuswa2w7u7ejVB7QVZaF+shsy1duKsYlbC/CEWK8z9v7oRgee9jEvDg?=
 =?us-ascii?Q?QFE4r9i6AkxbhCRZnUwgd+rC0mwhGAGSLiiVk3QwBCfy1DgolHZNWHcM/2Y9?=
 =?us-ascii?Q?2uUI/h/4g9xIjE+X/D0QVTh+mFaDWtfBtHJDY4fUEzPuYzjQSGdbzUBIUJpB?=
 =?us-ascii?Q?No3BgJYopFTkaKZE0viV0pvNHuy4MKoFqRkvGtEiEzeAOELKaFUQFp/mvC97?=
 =?us-ascii?Q?ATO3AhKkuCaazm2hMRn8jCswpqNH+PaPA2rX62jKNsxnKTLufGA3NidjqFDd?=
 =?us-ascii?Q?2VTwVh9QWLkfp/WWbXpuuKt1JBsM4aVkbIanmiL4NV+2l6HgXesldsDAaKwh?=
 =?us-ascii?Q?LTVE8J4fO7MwuanC5nBkrjtcUNkMHu2silQANB7b+uYR6q5J0hCgvGYfK3R/?=
 =?us-ascii?Q?1nQu1/UkQcn4ClkFjUO6I6sZwNs2md2L85+DNfytXXnkQU9ItYrl9YIfS8Gk?=
 =?us-ascii?Q?uaDWTfK2o0uxw2UVfSRUNTdLUPSi2sTVFIlFfLgh+DUqUj8UjF9K1PpnarFE?=
 =?us-ascii?Q?wtIkP7l3XReHpkOT9vrdA+cbtQSs1KIbW8OHJKPt7ZMfgMYqK3hIR7JRPZjO?=
 =?us-ascii?Q?j1Hg/oTCrHylxEmN8HOVnRTGTSUTAp2bDR+zBEnQSl/1Z/jyeteoF3WVui0O?=
 =?us-ascii?Q?nrNicQCPW/8ycMJmaMsL/BMjVnPihSITrpFeyuNavde5amtIYKCfenn1uMvr?=
 =?us-ascii?Q?kOz0GYoKdUhO5pTfKhJiYy5tV1ZEIYsFcgzQ41c2m8ZjUjP1UZ8thIrZCW21?=
 =?us-ascii?Q?pc2nN2qsnlYNM87qsoRtJGY6Octl7nyW0uhQvMFY0k6J9BzhxrKYx3fc7U/P?=
 =?us-ascii?Q?QFhV4KRecdOCJnHUHsZ5re9m8K+ZG3N/H/9FKAYdJI2gvAljAHT8Sobdi/cO?=
 =?us-ascii?Q?AfbmMKiawfNeipGqv1Z72lWyPuBEnjTfteYAZZfh?=
X-MS-Exchange-CrossTenant-Network-Message-Id: a06d5b7c-e0e6-4261-5317-08db996ca0b9
X-MS-Exchange-CrossTenant-AuthSource: CY5PR11MB6392.namprd11.prod.outlook.com
X-MS-Exchange-CrossTenant-AuthAs: Internal
X-MS-Exchange-CrossTenant-OriginalArrivalTime: 10 Aug 2023 06:40:04.1152
 (UTC)
X-MS-Exchange-CrossTenant-FromEntityHeader: Hosted
X-MS-Exchange-CrossTenant-Id: 46c98d88-e344-4ed4-8496-4ed7712e255d
X-MS-Exchange-CrossTenant-MailboxType: HOSTED
X-MS-Exchange-CrossTenant-UserPrincipalName: 7yt8r9Kj3feqiQLkdBrIAGhVqverq0+XjGh6HB2MCDMuAUFTlD/sbxFEPKkXTDybMo9Y1O7d5vVSb4C/EQExhA==
X-MS-Exchange-Transport-CrossTenantHeadersStamped: BL1PR11MB5544
X-OriginatorOrg: intel.com
Precedence: bulk
List-ID: <linux-ia64.vger.kernel.org>
X-Mailing-List: linux-ia64@vger.kernel.org

Hi Nathan, Hi Nick,

Could you kindly help to take a look at this report?

Quote Tony's comment:

> It seems that some/all of the combination of CLANG, ARCH=i386, and
> building with CONFIG_XXX=y rather than CONFIG_XXX=m makes clang freak
> out.
> GCC seems able to build the files in fs/resctrl2/arch/x86/ as either
> modules or built-in, x86_64 or i386 without problems.

We re-tested this case and got the same result as Tony's. GCC can build
this without problems, while various versions of clang (clang
17/16/15/14) throw this error. Could you help do a quick check to see if
necessary to track an issue? Thanks.

Best Regards,
Yujie

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
> 
> 
> vim +569 fs/resctrl2/arch/x86/l3_pseudolock.c
> 
>    568	
>  > 569	module_init(cat_init);
>    570	module_exit(cat_cleanup);
>    571	
> 
> -- 
> 0-DAY CI Kernel Test Service
> https://github.com/intel/lkp-tests/wiki
> 
