From: "Patil, Harish" <harish.patil@intel.com>
Date: Tue, 17 Dec 2002 16:33:38 +0000
Subject: [Linux-ia64] Re: gas generates incorrect ia64 unwind rlen values
Message-Id: <marc-linux-ia64-105590709805601@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590709805569@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590709805569@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> Mon, 16 Dec 2002 14:08:43 -0800, David Mosberger
<davidm@napali.hpl.hp.com> said:
> There have been many unwind-related bug fixes to the toolchain.  It's
> one reason why 2.9x is hopelessly obsolete.  Distros should really
> switch to gcc-3.2.
>	--david

David:

I have a RHAS kernel compiled with *gcc3.2*. Using a script based on
readelf/objdmp I found out that there are 7 instances in this kernel where
'rlen' may be wrong. The invariant the script is looking for is this:
	Sum(rlen for various regions) = Number of slots in the code range.

The script found following violations of the invariant:

<ia64_trace_syscall>: [0xe00000000440e1a0-0xe00000000440e240), info at
+0x54cdd8
        lo =  440E1A0  hi = 440E240
        sum_rlen =  28 no_slots = 30
            *******ERROR ***********
            sum_rlen: 28  != no_slots:30
<ia64_ret_from_clone>: [0xe00000000440e240-0xe00000000440e270), info at
+0x54ce08
        lo =  440E240  hi = 440E270
        sum_rlen =  7 no_slots = 9
            *******ERROR ***********
            sum_rlen: 7  != no_slots:9
<ia64_prepare_handle_unaligned>: [0xe00000000440e7a0-0xe00000000440e800),
info at +0x54cf70
        lo =  440E7A0  hi = 440E800
        sum_rlen =  17 no_slots = 18
            *******ERROR ***********
            sum_rlen: 17  != no_slots:18
<ia32_ret_from_clone>: [0xe0000000044506a0-0xe0000000044506d0), info at
+0x54fd00
        lo =  44506A0  hi = 44506D0
        sum_rlen =  7 no_slots = 9
            *******ERROR ***********
            sum_rlen: 7  != no_slots:9
<memset>: [0xe0000000049338a0-0xe000000004933cc0), info at +0x5803d0
        lo =  49338A0  hi = 4933CC0
        sum_rlen =  195 no_slots = 198
            *******ERROR ***********
            sum_rlen: 195  != no_slots:198
<memcpy>: [0xe0000000049365a0-0xe000000004936a40), info at +0x580618
        lo =  49365A0  hi = 4936A40
        sum_rlen =  219 no_slots = 222
            *******ERROR ***********
            sum_rlen: 219  != no_slots:222
code_range= 0xe000000004b18000-0xe000000004b182b0
        lo =  4B18000  hi = 4B182B0
        sum_rlen =  130 no_slots = 129
            *******ERROR ***********
            sum_rlen: 130  != no_slots:129

-Harish


