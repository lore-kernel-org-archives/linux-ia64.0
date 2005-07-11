From: "Magenheimer, Dan (HP Labs Fort Collins)" <dan.magenheimer@hp.com>
Date: Mon, 11 Jul 2005 15:09:45 +0000
Subject: RE: Xen and the Art of Linux/ia64 Virtualization
Message-Id: <516F50407E01324991DD6D07B0531AD54FA5EF@cacexc12.americas.cpqcorp.net>
List-Id: <linux-ia64.vger.kernel.org>
References: <516F50407E01324991DD6D07B0531AD54FA228@cacexc12.americas.cpqcorp.net>
In-Reply-To: <516F50407E01324991DD6D07B0531AD54FA228@cacexc12.americas.cpqcorp.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

> On Wed, 29 Jun 2005, Magenheimer, Dan (HP Labs Fort Collins) wrote:
> > Also unlike Xen/x86, Linux/ia64 with CONFIG_XEN enabled runs 
> > successfully on Xen, but also run natively on hardware (called 
> > "transparent paravirtualization").
> 
> That's neat indeed.
> 
> > This should be appealing to Linux/ia64 distributors as different
> > kernels need not be shipped for running on Xen or running native.
> 
> What's the performance impact for using transparanent 
> paravirtualization? 
> Is it sufficiently low that distributors really can consider using a 
> single kernel for both native and Xen "hosting"?

I ran a test over the weekend comparing kernel.org 2.6.12
compiled for a zx1 (rx2600) vs the same with transparent
paravirtualization enabled.  The test is compiling linux-2.6.12
(several times... I interrupted the second run) in
single-user mode.

As you can see, the performance impact is "in the noise".

If someone wants to run a benchmark that can be measured
with better precision than 1 part in 1000, please let
me know.

Dan

==
transparent paravirtualization
[djm@localhost djm]$ egrep '^real|^user|^sys' *048
05.07.11.071048:real    18m42.709s
05.07.11.071048:user    18m26.588s
05.07.11.071048:sys     0m25.431s
05.07.11.071048:real    18m33.756s
05.07.11.071048:user    18m27.412s
05.07.11.071048:sys     0m25.480s
05.07.11.071048:real    18m34.987s
05.07.11.071048:user    18m28.532s
05.07.11.071048:sys     0m25.700s
05.07.11.071048:real    18m35.458s
05.07.11.071048:user    18m28.976s
05.07.11.071048:sys     0m25.502s

native 2.6.12
[djm@localhost djm]$ egrep '^real|^user|^sys' *753
05.07.10.180753:real    18m43.805s
05.07.10.180753:user    18m27.958s
05.07.10.180753:sys     0m25.181s
05.07.10.180753:real    18m34.283s
05.07.10.180753:user    18m27.864s
05.07.10.180753:sys     0m25.414s
05.07.10.180753:real    18m34.513s
05.07.10.180753:user    18m28.247s
05.07.10.180753:sys     0m25.362s
