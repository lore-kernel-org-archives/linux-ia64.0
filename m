From: Takao Indoh <indou.takao@soft.fujitsu.com>
Date: Fri, 15 Oct 2004 02:11:08 +0000
Subject: Re: [PATCH 1/5][Diskdump] IPF(IA64) support
Message-Id: <34C4B25C3BFAE4indou.takao@soft.fujitsu.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1097804121.22673.43.camel@localhost.localdomain>
In-Reply-To: <1097804121.22673.43.camel@localhost.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Rusty Russell <rusty@rustcorp.com.au>
Cc: lkml - Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-ia64@vger.kernel.org

Hi!

On Fri, 15 Oct 2004 11:35:22 +1000, Rusty Russell wrote:

>On Fri, 2004-07-23 at 19:53, Takao Indoh wrote:
>> +static unsigned int fallback_on_err = 1;
>> +static unsigned int allow_risky_dumps = 1;
>> +static unsigned int block_order = 2;
>> +static int sample_rate = 8;
>> +module_param(fallback_on_err, uint, 0);
>> +module_param(allow_risky_dumps, uint, 0);
>> +module_param(block_order, uint, 0);
>> +module_param(sample_rate, int, 0);
>
>Hi Takao!
>
>	Are you sure you want "uint" for fallback_on_err and allow_risky_dumps
>and not "bool"?  Also, I suggest "0400" as permissions so you can read
>them out of sysfs; maybe even 0600 if these parameters can be changed
>after loading.

Thanks for comment.

The type of fallback_on_err and allow_risky_dumps is bool.
The latest version of diskdump (released on 28th Aug) is as follows.

+static int fallback_on_err = 1;
+static int allow_risky_dumps = 1;
+static unsigned int block_order = 2;
+static int sample_rate = 8;
+module_param_named(fallback_on_err, fallback_on_err, bool, S_IRUGO|S_IWUSR);
+module_param_named(allow_risky_dumps, allow_risky_dumps, bool, S_IRUGO|S_IWUSR);
+module_param_named(block_order, block_order, uint, S_IRUGO|S_IWUSR);
+module_param_named(sample_rate, sample_rate, int, S_IRUGO|S_IWUSR);


Regards,
Takao Indoh
