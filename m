From: Don Dugger <n0ano@n0ano.com>
Date: Thu, 21 Feb 2002 06:59:54 +0000
Subject: Re: [Linux-ia64] x86 compatability problem: ioctl() SIOCGIFCONF
MIME-Version: 1
Content-Type: multipart/mixed; boundary="Q68bSM7Ycu6FN28Q"
Message-Id: <marc-linux-ia64-105590701905157@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590701905147@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590701905147@msgid-missing>
To: linux-ia64@vger.kernel.org

--Q68bSM7Ycu6FN28Q
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Frank-

OK, here's a patch that should solve your problem.  It's a little
uglier than I'd like but there's not much I can do about that, at
least it works.

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
n0ano@n0ano.com
Ph: 303/449-0877

--Q68bSM7Ycu6FN28Q
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename="patch_0221.l"

--- kernel-bigsur-ref/arch/ia64/ia32/ia32_ioctl.c	Fri Nov  9 15:26:17 2001
+++ kernel-bigsur/arch/ia64/ia32/ia32_ioctl.c	Thu Feb 21 00:06:57 2002
@@ -79,6 +79,38 @@
 
 		      return ret;
 	      }
+		case IOCTL_NR(SIOCGIFCONF):
+		{
+			struct ifconf32 {
+				int		ifc_len;
+				unsigned int	ifc_ptr;
+			} ifconf32;
+			struct ifconf ifconf;
+			int i, n;
+			char *p32, *p64;
+			char buf[32];	/* sizeof IA32 ifreq structure */
+
+			if (copy_from_user(&ifconf32, P(arg), sizeof(ifconf32)))
+				return -EFAULT;
+			ifconf.ifc_len = ifconf32.ifc_len;
+			ifconf.ifc_req = P(ifconf32.ifc_ptr);
+			ret = DO_IOCTL(fd, SIOCGIFCONF, &ifconf);
+			ifconf32.ifc_len = ifconf.ifc_len;
+			if (copy_to_user(P(arg), &ifconf32, sizeof(ifconf32)))
+				return -EFAULT;
+			n = ifconf.ifc_len / sizeof(struct ifreq);
+			p32 = P(ifconf32.ifc_ptr);
+			p64 = P(ifconf32.ifc_ptr);
+			for (i = 0; i < n; i++) {
+				if (copy_from_user(buf, p64, sizeof(struct ifreq)))
+					return -EFAULT;
+				if (copy_to_user(p32, buf, sizeof(buf)))
+					return -EFAULT;
+				p32 += sizeof(buf);
+				p64 += sizeof(struct ifreq);
+			}
+			return ret;
+		}
 
 	      case IOCTL_NR(DRM_IOCTL_VERSION):
 	      {

--Q68bSM7Ycu6FN28Q--

