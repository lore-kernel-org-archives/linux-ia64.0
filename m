From: Alex Williamson <alex_williamson@hp.com>
Date: Tue, 06 Aug 2002 15:44:02 +0000
Subject: Re: [Linux-ia64] 2.4.9 vs 2.4.18 for HPC
Message-Id: <marc-linux-ia64-105590701905914@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590701905912@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590701905912@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

To name a few...

 - HP zx1 chipset support
 - McKinley Perfmon support
 - McKinley optimized assembly for copy_user, memcpy, copy_page

	Alex

Egan Ford wrote:
> 
> With respect to Itanium2 what advantages does 2.4.18 have over 2.4.9 in
> an HPC environment?
> 
> My concern is that RH7.2 does not have a 2.4.18/19 kernel and probably
> will not.  For support reasons, running 2.4.9-34 from RH may be
> required.  I am curious about the possible performance and stability
> issues with 2.4.9 on Itanium2.
> 
> I am trying to build a case for software development on 2.4.18/19
> kernel.org kernels.
> 
> Thanks.
> 

--
Alex Williamson                                  Linux Development Lab
alex_williamson@hp.com                                 Hewlett Packard
970-898-9173                                          Fort Collins, CO

