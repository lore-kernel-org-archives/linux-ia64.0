From: Uros Prestor <uros@turbolinux.com>
Date: Tue, 08 Aug 2000 18:26:09 +0000
Subject: Re: [Linux-ia64] Kernel: which machine to choose?
Message-Id: <marc-linux-ia64-105590678205277@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590678205272@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590678205272@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

David Mosberger wrote:

> I wouldn't recommendn turning on AzusA hacks unless you have an AzusA
> machine.

Why is that?  Our kernels have been compiled with AzusA hacks enabled and we had no problems
with our kernels running on BigSurs and Lions.

On another note, we are getting a lot more segfaults during builds lately.  The 0505 release
which had the 2.3.99-pre6 kernel was rock solid; after moving to 2.4.0 kernels the segfaults
came back with a vengeance.  We did upgrade processors from A2 to A3 but I don't think this
could be a culprit.  Any ideas on this?

Thanks,
Uros

--
Uros Prestor
uros@turbolinux.com




