From: Randolph Chung <randolph@tausq.org>
Date: Tue, 03 Sep 2002 17:46:43 +0000
Subject: Re: [Linux-ia64] latest glibc snapshot does not build on ia64?
Message-Id: <marc-linux-ia64-105590701906011@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590701906009@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590701906009@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

In reference to a message from Wichmann, Mats D, dated Sep 03:
> 
> > Haven't dug into this too much yet; wanted to see if anyone else has
> > seen this?
> 
> Yup.
> 
> There's a short glibc patch which takes care of this (should be on the
> Debian lists, else I can mail it to you once I get my machine back up).
> It's an "unofficial"  patch because it's felt the problem really lies 
> with binutils and not glibc, so it's not in glibc cvs.   The change
> is to dl-machine.h if it helps search...

there was a IA64_RELOC_NONE patch, but in a different area of glibc...
looks like we just hit it again at a different spot now...


    580   /* ??? Ignore MSB and Instruction format for now.  */
    581   if (R_IA64_FORMAT (r_type) = R_IA64_FORMAT_64LSB)
    582     *reloc_addr = value;
    583   else if (R_IA64_FORMAT (r_type) = R_IA64_FORMAT_32LSB)
    584     *(int *) reloc_addr = value;
    585   else if (r_type = R_IA64_IPLTLSB)
    586     {
    587       reloc_addr[0] = 0;
    588       reloc_addr[1] = 0;
    589     }
    590   else
    591     assert (! "unexpected dynamic reloc format");

r_type is 0 at the assertion 

randolph

