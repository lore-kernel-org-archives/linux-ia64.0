From: Petr Tesarik <ptesarik@suse.cz>
Date: Wed, 14 Nov 2007 07:55:38 +0000
Subject: Re: [PATCH] ptrace RSE bug
Message-Id: <473AA9FA.6020308@suse.cz>
MIME-Version: 1
Content-Type: multipart/mixed; boundary="------------010106020301080800070500"
List-Id: <linux-ia64.vger.kernel.org>
References: <1188357710.22637.7.camel@sli10-conroe.sh.intel.com>
In-Reply-To: <1188357710.22637.7.camel@sli10-conroe.sh.intel.com>
To: linux-ia64@vger.kernel.org

This is a multi-part message in MIME format.
--------------010106020301080800070500
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit

Roland McGrath wrote:
>> I found it extremely difficult to trigger the race condition without the
>> articifial test - arch_ptrace_stop() only sleeps if the user page is not
>> present, but in the common case the register stack backing store will
>> have been quite recently accessed by the process.
> 
> It is supposed to be a rare race, after all. :-)  We're just being thorough
> to cover it, not that it ever actually happened in practice or was expected to.
> 
>> It should be possible to create a large file, flush the page cache, put
>> the RSE into lazy mode, flush it and map the register stack from that
>> file, so that no memory accesses to the backing store are done before
>> ptrace_stop(), but for the time being I placed an msleep(100) after
>> arch_ptrace_stop().
> 
> And then make the file so mapped be from a broken NFS or FUSE or somesuch
> mount that actually blocks forever on the fault.  That would be the
> probable style of a DoS attack exploiting this to create unkillable processes.

That's exactly what I did. FUSE doesn't implement mmap (guess why), but
I was able to trigger the race even with a working NFS after tweaking
the timing a bit. I'm attaching the test case I used (the NFS volume was
mounted on /nfs).

Regards,
Petr Tesarik

--------------010106020301080800070500
Content-Type: application/gzip;
 name="sigkill-race.tar.gz"
Content-Transfer-Encoding: base64
Content-Disposition: inline;
 filename="sigkill-race.tar.gz"

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
jnSkIx3pSEc60pGOdKT/Pfo3DFc4KQAoAAA=
--------------010106020301080800070500--
