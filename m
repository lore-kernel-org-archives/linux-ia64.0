Return-Path: <linux-ia64-owner@vger.kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from vger.kernel.org (vger.kernel.org [23.128.96.18])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 8521EE7D0A2
	for <linux-ia64@archiver.kernel.org>; Thu, 21 Sep 2023 20:08:42 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S231337AbjIUUIp (ORCPT <rfc822;linux-ia64@archiver.kernel.org>);
        Thu, 21 Sep 2023 16:08:45 -0400
Received: from lindbergh.monkeyblade.net ([23.128.96.19]:45642 "EHLO
        lindbergh.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S231602AbjIUUI3 (ORCPT
        <rfc822;linux-ia64@vger.kernel.org>); Thu, 21 Sep 2023 16:08:29 -0400
Received: from mgamail.intel.com (mgamail.intel.com [192.55.52.43])
        by lindbergh.monkeyblade.net (Postfix) with ESMTPS id 956865FC2
        for <linux-ia64@vger.kernel.org>; Thu, 21 Sep 2023 12:42:56 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple;
  d=intel.com; i=@intel.com; q=dns/txt; s=Intel;
  t=1695325376; x=1726861376;
  h=message-id:date:subject:to:cc:references:from:
   in-reply-to:content-transfer-encoding:mime-version;
  bh=k8/yPFl1lVuh6YHk51tZ9ApwhDjr52SYbY44n3jNQQ4=;
  b=dho2M01cjzOWKiyvbJz+oj8dqThWWmBiF5VOVY0J4B19T4RaX9JVUN5v
   uaLjx3TutVInmty86Vh1LiiKBzKwrQf7iM0RRyANyWgwyGDUSoi59MGz+
   2yTJPS1lB/ORV9kL9BOO3vkd3vy45+3bnlpUvLH8wlYjk7hdmQchmjQpO
   Uck8CtkGBYgqQTuwooWB8ZbpFQoF1XdJ9x6Mc+brkRPhqmyweE4xx2fM4
   bmHWeV1dMjNZ/RRKRvYmaX8egdZ790tsiMc2MQfFo9J5NmdNcfRFmHcMH
   /IC5WJ7RtlHov+Zb4wVxAE0yyqs8AFctd9icyZw5mcVQw4Ks6+Qbs8CkY
   A==;
X-IronPort-AV: E=McAfee;i="6600,9927,10840"; a="466946615"
X-IronPort-AV: E=Sophos;i="6.03,166,1694761200"; 
   d="scan'208";a="466946615"
Received: from fmsmga007.fm.intel.com ([10.253.24.52])
  by fmsmga105.fm.intel.com with ESMTP/TLS/ECDHE-RSA-AES256-GCM-SHA384; 21 Sep 2023 12:42:56 -0700
X-ExtLoop1: 1
X-IronPort-AV: E=McAfee;i="6600,9927,10840"; a="750525831"
X-IronPort-AV: E=Sophos;i="6.03,166,1694761200"; 
   d="scan'208";a="750525831"
Received: from fmsmsx601.amr.corp.intel.com ([10.18.126.81])
  by fmsmga007.fm.intel.com with ESMTP/TLS/AES256-GCM-SHA384; 21 Sep 2023 12:42:56 -0700
Received: from fmsmsx610.amr.corp.intel.com (10.18.126.90) by
 fmsmsx601.amr.corp.intel.com (10.18.126.81) with Microsoft SMTP Server
 (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_128_GCM_SHA256) id
 15.1.2507.32; Thu, 21 Sep 2023 12:42:55 -0700
Received: from fmsedg602.ED.cps.intel.com (10.1.192.136) by
 fmsmsx610.amr.corp.intel.com (10.18.126.90) with Microsoft SMTP Server
 (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_128_GCM_SHA256) id
 15.1.2507.32 via Frontend Transport; Thu, 21 Sep 2023 12:42:55 -0700
Received: from NAM10-BN7-obe.outbound.protection.outlook.com (104.47.70.109)
 by edgegateway.intel.com (192.55.55.71) with Microsoft SMTP Server
 (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.1.2507.32; Thu, 21 Sep 2023 12:42:55 -0700
ARC-Seal: i=1; a=rsa-sha256; s=arcselector9901; d=microsoft.com; cv=none;
 b=XnsxS5RuBSIESssugujKXG55KBOdJWpwf4P8OVdncglidcyeUx/wdq0lkPWh3GwwdFXU9yoMPKDDGTtReXpQ/2XwqrYf/tjW8erHhGwdAMH/sRrObs2ykwiUN1qTlE52w1l2q5GTypOUQRfnUiNd5kBRScL3AQrvBjxVrKTEcWfO1UjS60rp4oVKM/BdScq66xeHwrlZW42VarH88v+n8ArLcwkv4mCsiSLGlEZ0zlb7H6lekMAt6BEpVC0iA0ds4a9xp4E23jXeBr1p4sIQr5tA7eaH4odoOCc5fdxNqzB2MKWMCSw5KLEe7FTpiL46EejISgdt8InWfnl+yzI6lQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=microsoft.com;
 s=arcselector9901;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-AntiSpam-MessageData-ChunkCount:X-MS-Exchange-AntiSpam-MessageData-0:X-MS-Exchange-AntiSpam-MessageData-1;
 bh=f0PQCB+GvwIx4O0Uk7CarBRnOmghe9QjFpWe8hWsNpY=;
 b=EMP82FbBVoM7AuKt8r5CWXHkVjQaBPfpRe0i4AdbvgIO2vwrbRXXnI9ARyivdmOQFRT/33Wz+SIa4DT6QcY6sT5TDlT5mW5pZaCYJ/Gta3Rue6Vdjt6aM+Z6yuCHaIPnpNh6DkkbzwqrqleLNu2fr8fRrh00wV4rjDMbaldu+IB61PfwfTZXMQ5e+7d7FLHOjVqXJGbSBx+ZIqJSl2alpL/lPWyb01Al0sxuTrnqXwIu1y7y4IqrlUxSgEj5mW5SlWX2kDBwLwh2p5OJbklxDgTJv/fXC4Twq7AelzvXURil19qWANgORuTbM1K6zDD68Nd1rZVR9AWZrsZ+3ppANw==
ARC-Authentication-Results: i=1; mx.microsoft.com 1; spf=pass
 smtp.mailfrom=intel.com; dmarc=pass action=none header.from=intel.com;
 dkim=pass header.d=intel.com; arc=none
Authentication-Results: dkim=none (message not signed)
 header.d=none;dmarc=none action=none header.from=intel.com;
Received: from MW5PR11MB5810.namprd11.prod.outlook.com (2603:10b6:303:192::22)
 by CH0PR11MB5346.namprd11.prod.outlook.com (2603:10b6:610:b9::13) with
 Microsoft SMTP Server (version=TLS1_2,
 cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id 15.20.6813.20; Thu, 21 Sep
 2023 19:42:52 +0000
Received: from MW5PR11MB5810.namprd11.prod.outlook.com
 ([fe80::c79d:298b:c747:6d65]) by MW5PR11MB5810.namprd11.prod.outlook.com
 ([fe80::c79d:298b:c747:6d65%4]) with mapi id 15.20.6792.026; Thu, 21 Sep 2023
 19:42:52 +0000
Message-ID: <524cbf0e-7572-6398-e0e3-18fa62a1185f@intel.com>
Date:   Thu, 21 Sep 2023 21:42:45 +0200
User-Agent: Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:102.0) Gecko/20100101
 Thunderbird/102.15.1
Subject: Re: Build regression since v6.6-rc1
To:     Ard Biesheuvel <ardb@kernel.org>,
        Frank Scheiner <frank.scheiner@web.de>,
        Arnd Bergmann <arnd@arndb.de>
CC:     <linux-ia64@vger.kernel.org>, <michal.wilczynski@intel.com>,
        debian-ia64 <debian-ia64@lists.debian.org>,
        Linus Torvalds <torvalds@linux-foundation.org>,
        John Paul Adrian Glaubitz <glaubitz@physik.fu-berlin.de>
References: <adc65a97-2479-8779-0e09-4ec2fe946cb2@web.de>
 <CAMj1kXGDVWYJMHJay3j8P=EQMMv1cmSLRDoiDBrt1hdvZpOpww@mail.gmail.com>
Content-Language: en-US
From:   "Wysocki, Rafael J" <rafael.j.wysocki@intel.com>
In-Reply-To: <CAMj1kXGDVWYJMHJay3j8P=EQMMv1cmSLRDoiDBrt1hdvZpOpww@mail.gmail.com>
Content-Type: text/plain; charset="UTF-8"; format=flowed
Content-Transfer-Encoding: 7bit
X-ClientProxiedBy: FR4P281CA0001.DEUP281.PROD.OUTLOOK.COM
 (2603:10a6:d10:c8::15) To MW5PR11MB5810.namprd11.prod.outlook.com
 (2603:10b6:303:192::22)
MIME-Version: 1.0
X-MS-PublicTrafficType: Email
X-MS-TrafficTypeDiagnostic: MW5PR11MB5810:EE_|CH0PR11MB5346:EE_
X-MS-Office365-Filtering-Correlation-Id: fa4316b1-9dec-4ccf-a67e-08dbbadaf180
X-LD-Processed: 46c98d88-e344-4ed4-8496-4ed7712e255d,ExtAddr
X-MS-Exchange-SenderADCheck: 1
X-MS-Exchange-AntiSpam-Relay: 0
X-Microsoft-Antispam: BCL:0;
X-Microsoft-Antispam-Message-Info: sxFbBGdbLGc7o9LBQLQoqRFWhdLDU7AjWOy7e2s4cW6H+IKFSg4quA8qUQliRAEz0Nz+rNb9+moviSJAIhtC2pmo5DLnbsD7tW257mj+Y0ur2yzEph6GSxGx/mgru2Y5X0+36rHjOnFk5hM8xDJqloghtU9YFa7pZsy8XYDuLcKNEoH3+8vK5Isnx+BwfhShPLWKU1nxUx2egIip/XH4zEEZZ6Z07HKtGisLjvsgaaTb9MCKPkDFnj//L78aZPnP8y3tkXX66f1m4EZlY6O6UGBoVvnLAi3XdWLODcC0Z5jfq15LGuy/SkU/GlN0qW5yoQ07GyYIRdd1wOtH5xSPu7FDQQ7ZZKKY5mHwghffSnDXCRSYDtc0NbdrOg8wEszxMdk3AH8J5Ioo/M/QhZwVdsomG+KYfLU+xEcbKUupAOVKTV8h11r7iEznRe/k3VWg+QXLfixJUqXYyEivA8Y+HU0Or/NEgXvUrtQc5+ZwnpneC4zavkYE8/d0FWHlx7J2Bp3yxTiavOohxuqYNgH9MUBXXnvml2vQFZ8Rsj0IrPBRdyKK/073kpbS/BzT6bErfNtctJ6D/xOXwsyJLtNZ/JJ7+uhSGhiVfzidI9lEVWrlccgngmRJQ4OeS2+pJZlXM2KjJUjsAGE24fVQSZuAFhcES1w3aS1A0aqxfSolb+iS/TT7DEy4IidSMPkdX89J
X-Forefront-Antispam-Report: CIP:255.255.255.255;CTRY:;LANG:en;SCL:1;SRV:;IPV:NLI;SFV:NSPM;H:MW5PR11MB5810.namprd11.prod.outlook.com;PTR:;CAT:NONE;SFS:(13230031)(346002)(366004)(39860400002)(136003)(376002)(396003)(1800799009)(451199024)(186009)(31686004)(6506007)(6666004)(6512007)(53546011)(82960400001)(6486002)(38100700002)(31696002)(36756003)(86362001)(2906002)(83380400001)(110136005)(478600001)(966005)(2616005)(26005)(4326008)(5660300002)(41300700001)(66556008)(316002)(8676002)(66476007)(66946007)(54906003)(8936002)(43740500002)(45980500001);DIR:OUT;SFP:1102;
X-MS-Exchange-AntiSpam-MessageData-ChunkCount: 1
X-MS-Exchange-AntiSpam-MessageData-0: =?utf-8?B?UFY3R0J2SHRTVjRyMWNlSXpMNzZ3cnlwRzFwVnpJQzlXQXFEelhpRmdsUTBM?=
 =?utf-8?B?WUtFbXNyY0VPQlB5T1pGQ3UvcnV6ZHdsVTh6UHNaSFNJeFpudSt0MjJCc2kv?=
 =?utf-8?B?NFdmdzkzcVcrQzNtM010citPRFpXL2haeFRXVi91RVo1QWdrZ1o1UGZ4RFZx?=
 =?utf-8?B?ZXdJVkZKblVmaXZLQU94VlNsOFlNaGZNcTE0ZjZnenJvaWxxeEdWOXRSNjgy?=
 =?utf-8?B?eWowQS9rYWt3TS9ScFB1WFQwSUFYTWliSnp0S3ZxV1lzZ2FhUXdIVGMwZVlZ?=
 =?utf-8?B?SkdMZU1KTDBuVE9OMGdocWZBbkszS2xwWGlmWmZncXE3NTlLdk1pNlJ3V1Fi?=
 =?utf-8?B?YVRFQmdLMVlXYlBtVjFWVmdZNUt6VzhsK21XVGJ2dU9ITHlDUXMxa3RiMUJY?=
 =?utf-8?B?TkV1Um5JZ2kzRjlDelVZRysrWUR3bGZZQkFOZzJIU3N3QkVzSEtwb0FydUlN?=
 =?utf-8?B?SnRzMzdGTXBEWjdIbjNZU2RMbWRxamk4bVVuamVNSlR0M3N0V2kwRFhId21x?=
 =?utf-8?B?VEdiaU8rL2pJbkd6RnRKUG83UWNOdEVtU3UxY1lLckpWMmRoNXRrajBOZzBt?=
 =?utf-8?B?V2JGbjRKWkxNbmlUT0wydlE2VE1CUEd1Q3EzN1MvSDVETWJ6WjZjeU1yRVlP?=
 =?utf-8?B?NDMvNjV3NC9qd3loVEZRRTFNZWdLOGpFWFplVSttTWk1aE43K3hYTjZaZGVM?=
 =?utf-8?B?MEdTZitzODUyZmF3cWpWbTlORWRacVFGMmdGUkRMVFIzRnp6bnpETUQydXNt?=
 =?utf-8?B?NkdyUExJTHllaGZVVkJlQTQrTVNONkNqNENiZDFlRmtYREtaa0dGQk1zdCsz?=
 =?utf-8?B?ZDBZK3VKY0tQVkpzeUJtRmdqdVZsRTRDSnlmb0tRNTVRb0FLRUg0bWl0Rm1h?=
 =?utf-8?B?RmcrZnFaVFpjUlBCS2tuaFcyNHF3VVl5RHVWbFlVQUFwendvRDRRMnlxUFVv?=
 =?utf-8?B?UW9rMGMvdTNraGJpUEFlS0hyeldrQkVCZU1jQlpkSWxUSHhWdlF2dW1zeUNy?=
 =?utf-8?B?eU0xRnQySmt0UCtzTUhCYktMdDIvUkxYOUgrSUJvNDJDa1hZNlVpUWFxQkU1?=
 =?utf-8?B?Mkl3eWZxVjJtNVV2bGQxNEhyWVlNcGdlL2ZvOTRha2JxTE5XVFpUbWFhazYv?=
 =?utf-8?B?b0FzLzNDMVFqWWZtaEhqdkJWTDFTY3kyQk9WMTY0S3hHc3VJa1VzZEJVK2M3?=
 =?utf-8?B?Yys1MmNScWttakxzdUVrTWZCc2U5WDRuN1FIR21tUUJZVjNKUC9pOG4raTM1?=
 =?utf-8?B?c1FiajZoTE9aVnd1eTljYTJ3djFXVHI1czBkUkI5V0hhd0s3ZGZ2SWsyOE1t?=
 =?utf-8?B?ZlpDb3lpSEl5STdFR3dXNjRwQ0h4UU1PVy9XMXFnUjhDdXBEUGV0d0xwQTVH?=
 =?utf-8?B?M1hpZmhDc3ZkcVpXdkgxZEFweWdEWEJXVkFGVVhrSS9Tb1FtbFBHQjM0YmZX?=
 =?utf-8?B?cVJ5Z2JZUlo2SjJiRnJOSGRBYUZjREVMQ1VkWmZzM0lVSGRDdVo5T0lNNXIw?=
 =?utf-8?B?Tm45dVBPK1hXVXdGdEV1UzU0M29PbXRTNjdIcDYycEZSMFRuT213MHdTUHdz?=
 =?utf-8?B?NWloQlpLejZkMDJnYjVpRGJFN2twZG91TkxZTHRDOFV4RGxwQVcwNEMyMnNF?=
 =?utf-8?B?MXpIYnpnaHc4VVhNT0lUbTJ6Z3p1QWRoWStMUHNzMm03aEF1UGFWRmRrL1Z5?=
 =?utf-8?B?VmNwTmhtOTJuZDVZdDJiZTJOdVJhZG5ZMXd4WXl4OHJWSjRkTHNqc0JCT1dj?=
 =?utf-8?B?N3ZaSFAvV2YyUDdXbFdrbFlHL2RpQU1iaXdQamo3dm5wMXpLc1NuVWxaaDZk?=
 =?utf-8?B?YWZVZVR2aDNXUExmRkRZTnhudXFxOHZwM0NOWFc4NVRuVFBFaXU4Qm0wUVNw?=
 =?utf-8?B?OElweUI0UEttZHIrbDk2VVc3RjEzanBzNmNwY1VreHVVQWRXZWlEbnIrVWFZ?=
 =?utf-8?B?MzIzdlQwYmNRc1Uvb2FPaDJqV3ZySGExY1lpVUZyazlGNWFyemgwdUNXT2V5?=
 =?utf-8?B?L2d4eFdLaytuSUZkT1RBSnZVT1ZHc2xGVXIyRTFsNzJxMGQ3VUZ1dktIWWll?=
 =?utf-8?B?NURSNTUwTVpCdHRkdm9ReDdKV0ZqNU9ZV25rMndIWnZXcXVVWC9sYk1QSThS?=
 =?utf-8?B?SG1MQWtWOFRYNEpLTzhhd1QvMWVwWGkzeFJPcWNZMGNqbFhsV1FOTGprcHpM?=
 =?utf-8?B?SXc9PQ==?=
X-MS-Exchange-CrossTenant-Network-Message-Id: fa4316b1-9dec-4ccf-a67e-08dbbadaf180
X-MS-Exchange-CrossTenant-AuthSource: MW5PR11MB5810.namprd11.prod.outlook.com
X-MS-Exchange-CrossTenant-AuthAs: Internal
X-MS-Exchange-CrossTenant-OriginalArrivalTime: 21 Sep 2023 19:42:52.3269
 (UTC)
X-MS-Exchange-CrossTenant-FromEntityHeader: Hosted
X-MS-Exchange-CrossTenant-Id: 46c98d88-e344-4ed4-8496-4ed7712e255d
X-MS-Exchange-CrossTenant-MailboxType: HOSTED
X-MS-Exchange-CrossTenant-UserPrincipalName: +nXvIZasq5HspsiA98PvvXAQajbr4ewDtybgu9+hU5vY3eYiUVeNna/CtuaKvFTlMU+8iGYvlzf6y6tiZ1VYoGAY4BrLRkaBffiorGnnwiQ=
X-MS-Exchange-Transport-CrossTenantHeadersStamped: CH0PR11MB5346
X-OriginatorOrg: intel.com
Precedence: bulk
List-ID: <linux-ia64.vger.kernel.org>
X-Mailing-List: linux-ia64@vger.kernel.org

On 9/21/2023 1:53 PM, Ard Biesheuvel wrote:
> Hello Frank,
>
> On Thu, 21 Sept 2023 at 10:15, Frank Scheiner <frank.scheiner@web.de> wrote:
>> Dear all,
>>
>> since v6.6-rc1 (actually introduced with [1], specific commit on [2])
>> the kernel build for ia64 fails like that:
>>
>> ```
> ...
>> Could one ([5]) or the other ([6]) please be included in v6.6 (or
>> earlier) to "fix" the build problem for ia64?
>>
> Do you mean by "fix" that the proposed fixes are just workarounds and
> not proper fixes? I don't think that is the case - the function in
> question does nothing except apply a quirk for one specific x86
> platform.
>
> ...
>> [5]:
>> https://lore.kernel.org/lkml/CAJZ5v0hnNK4O_HyinvTp01YxXR7V4vzpMhf85yW9M2=52-O2Fg@mail.gmail.com/
>>
>> [6]:
>> https://git.kernel.org/pub/scm/linux/kernel/git/ardb/linux.git/commit/?id=a0334bf78b95532cec54f56b53e8ae1bfe7e1ca1
> Either Arnd, Rafael or myself should send a PR to Linus to merge [6]
> as a fix, as it is already queued up in -next for v6.7.
>
> Or perhaps Linus doesn't mind grabbing it from here:

I have pulled this and I will send a pull request including it tomorrow 
(unless Linus beats me to it and pulls it himself).


>
> ------------8<--------------
>
> The following changes since commit 0bb80ecc33a8fb5a682236443c1e740d5c917d1d:
>
>    Linux 6.6-rc1 (2023-09-10 16:28:41 -0700)
>
> are available in the Git repository at:
>
>    git://git.kernel.org/pub/scm/linux/kernel/git/ardb/linux.git
> tags/fix-ia64-build-for-v6.6
>
> for you to fetch changes up to a0334bf78b95532cec54f56b53e8ae1bfe7e1ca1:
>
>    acpi: Provide ia64 dummy implementation of
> acpi_proc_quirk_mwait_check() (2023-09-11 08:13:17 +0000)
>
> ----------------------------------------------------------------
> Build fix for Itanium/ia64:
>
> - provide dummy implementation of acpi_proc_quirk_mwait_check() which
>    was moved out of generic code into arch/x86, breaking the ia64 build
>
> ----------------------------------------------------------------
> Ard Biesheuvel (1):
>        acpi: Provide ia64 dummy implementation of acpi_proc_quirk_mwait_check()
>
>   arch/ia64/kernel/acpi.c | 4 ++++
>   1 file changed, 4 insertions(+)
