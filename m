From: n0ano@indstorage.com
Date: Wed, 20 Feb 2002 17:21:21 +0000
Subject: Re: [Linux-ia64] x86 compatability problem: ioctl() SIOCGIFCONF
Message-Id: <marc-linux-ia64-105590701905149@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590701905147@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590701905147@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Frank-

Support for IA32 `ioctl's is a hard problem, most have to be dealt
with on a case by case basis.  This is just one that got missed.
This one shouldn't be to difficult, give me a day or two and I
should be able to send out a patch to fix it.

On Wed, Feb 20, 2002 at 11:03:51AM -0600, Tseng-hui Lin wrote:
>     I need to keep some x86 code alive in IA64 land. It looks like ioctl()
> SIOCGIFCONF function doesn't work. I compiled the attached test program on
> an x86 machine and ran it on an RedHat 7.2 Linux/IA64. It gave me "ioctl
> SIOCGIFCONF: Bad address". The program works if it is compiled and run on
> an IA64 machine. I know that the sizes of struct ifreq are different on x86
> and IA64. However, it hasn't reached that part yet. I thought it might be
> memory alignment problem since ioctl() returns "Bad address". I put some
> paddings to make the variables allocated on 8-byte boundary but the problem
> is still there. Has any one seen this problem before?
> 
> #include <stdio.h>
> #include <stdlib.h>
> #include <unistd.h>
> #include <sys/ioctl.h>
> #include <sys/socket.h>
> #include <net/if.h>
> 
> #define MAX_NUM_IFREQ (512)
> 
> main() {
>     struct ifconf       Ifc;
>     struct ifreq        IfcBuf[MAX_NUM_IFREQ];
>     struct ifreq        *pIfr;
>     int num_ifreq;
>     int i;
>     int fd;
> 
>     Ifc.ifc_len = sizeof(IfcBuf);
>     Ifc.ifc_buf = (char *) IfcBuf;
> 
>     if ((fd = socket(AF_INET, SOCK_DGRAM, 0)) < 0) {
>         perror("socket()");
>         exit(1);
>     }
>     if ( ioctl(fd, SIOCGIFCONF, &Ifc) < 0) {
>         perror("ioctl SIOCGIFCONF");
>         exit(1);
>     }
>     num_ifreq = Ifc.ifc_len / sizeof(struct ifreq);
>     for ( pIfr = Ifc.ifc_req, i = 0 ; i < num_ifreq; pIfr++, i++ ) {
>         printf("%d: %s<=\n", i, pIfr->ifr_name);
>     }
> }
> 
> Tseng-Hui (Frank) Lin  tsenglin@us.ibm.com
> Phone:(512)838-8312  T/L 678-8312
> FAX: (512)838-3484 T/L 678-3484
> IBM Poughkeepsie Unix Development Lab, Dept XXWA
> Building 905-2H018, 11501 Burnet Road, Austin, TX 78758
> 
> 
> _______________________________________________
> Linux-IA64 mailing list
> Linux-IA64@linuxia64.org
> http://lists.linuxia64.org/lists/listinfo/linux-ia64

-- 
Don Dugger
"Censeo Toto nos in Kansa esse decisse." - D. Gale
n0ano@indstorage.com
Ph: 303/652-0870x117

