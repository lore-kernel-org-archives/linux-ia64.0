From: Alex Williamson <alex_williamson@hp.com>
Date: Mon, 17 Mar 2003 15:17:23 +0000
Subject: Re: [Linux-ia64] rx2600 HW-error only when running 2.4.20
Message-Id: <marc-linux-ia64-105590709806139@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590709806136@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590709806136@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Steinar Traedal-Henden wrote:
> 
> Hi,
> 
> I get the following HW error on a HP rx2600 when I run my own compiled
> 2.4.20 kernel.
> 
> Mar 17 04:13:35 compute-1-0 kernel: +BEGIN HARDWARE ERROR STATE AT CPE
> Mar 17 04:13:35 compute-1-0 kernel: +Err Record ID: 2833    SAL Rev:  0.02
> Mar 17 04:13:35 compute-1-0 kernel: +Time: 03/17/2003 04:19:49    Severity 2
> Mar 17 04:13:35 compute-1-0 kernel: +Platform PCI Bus Error Info Section
> Mar 17 04:13:35 compute-1-0 kernel: + PCI Bus Error Detail:  Error Status: 0x4a1700 Error Type: 0x0 Bus ID: 0x80 Bus Address: 0x0 Responder ID: 0xfed28000+END HARDWARE ERROR STATE AT CPE

   You're getting a CPE (Corrected Platform Error) record.  Polling
for CPEs was added in 2.4.20, so it's not surprising you didn't see
them before.  The good news is that the error is corrected, this is
just the system telling you about it.  You should probably try to
figure out what the problem is though in case it leads to uncorrectable
problems that will MCA your box.  Most of the error record is documented
in the SAL spec.  Here's what we can determine:

Error Status: 0x4a1700

 - bit8-15 = Error Type 0x17 = 23 = ERR_PROTOCOL (Detection of a protocol error) 
 - bit 17 = Control: Error was detected on the control signals or in
            the control portion of the transaction
 - bit 19 = Responder: Error was detected by the responder of the transaction
 - bit 22 = Overflow 
  
Error Type: 0x0 = Unknown or OEM System Specific Error

What do you have in the slot corresponding to bus 0x80?  An lspci -vvv
might be helpful.  If you go back to an EFI Shell and run 'errdump cpe'
that might provide us with more information about what's happening.
Thanks,

	Alex

--
Alex Williamson                             HP Linux & Open Source Lab

