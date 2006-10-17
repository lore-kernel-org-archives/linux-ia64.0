From: Jay Lan <jlan@engr.sgi.com>
Date: Tue, 17 Oct 2006 00:21:03 +0000
Subject: Re: A regression in IA64 kexec/kdump patch for 2.6.18?
Message-Id: <453421EF.6040205@engr.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <4533F2BE.3070300@engr.sgi.com>
In-Reply-To: <4533F2BE.3070300@engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org

Zou Nan hai wrote:
> On Tue, 2006-10-17 at 04:59, Jay Lan wrote:
>> I ran into a problem not seen in kexec/dkump 2.6.17rc5 ia64 patch.
>> The system on test was an Altix.
>>
>   You mean 2.6.18rc5 patch?

Oops, yes, i meant 2.6.18rc5... although i found the kernel patch
was not the cause. See below.

>> The system was booted up fine; however, after loading 'kexec -p'
>> and "echo c >/proc/sysrq-trigge=C5=95", the crashdump kernel would try
>> to boot up and restarted the system near the end of init().
>>
>> The extraodinary message observed on the console was
>>     Warning: unable to open an initial console
>>
>> but the actual reboot seems to be invoked in running /sbin/init:
>>     run_init_process("/sbin/init");
>>
>> The problem is 100% reproducible. I have disabled all cpus except
>> cpu0 in my testing.
>>
>> Is this a known problem? Anyone else runs into this?
>>
>   It seems to be an incorrect initrd problem

No, i used the correct initrd. I would not be able to boot the
kernel/initrd pair as the 1st kernel (sytstem kernel) if the
initrd was incorrect.

Well, i built 2.6.18 kernel and 2.6.18rc5 kernels.
I also built 2 kexec-tools based on kdump10 patch. I have been
associating the kexec-tools tree that i built at the rc5 time with
the rc5 kernel and the newer kexec-tools tree with the 2.6.18
kernel.

I just ran a few tests with different combination of kexec-tools
and kernels. Well, it showed that the rc5 version of kexec-tools
worked correctly with both kernels, but the newer version of
kexec-tools displayed the system restart problem with both kernels.

So, it was the kexec-tools that caused the problem. Not the kernel
side. I will diff the patches i applied to both trees...

Later,
 - jay



>=20
>   Zou Nan hai
>> Thanks,
>>  - jay
> -
> To unsubscribe from this list: send the line "unsubscribe linux-ia64" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

