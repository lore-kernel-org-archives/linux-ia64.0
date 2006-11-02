From: Keith Owens <kaos@sgi.com>
Date: Thu, 02 Nov 2006 07:25:15 +0000
Subject: Re: [PATCH]IA64 trap code 16 bytes atomic copy on montecito, take 2
Message-Id: <22990.1162452315@kao2.melbourne.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <454961EE.4070608@intel.com>
In-Reply-To: <454961EE.4070608@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Keith Owens (on Thu, 02 Nov 2006 18:22:58 +1100) wrote:
>/me kicks himself for mixing up src and dest.
>
>extern ld16_st16(dest, src);
>
>ENTRY(ld16_st16)
>	ld16 r15=[r32]		// src
>	;;
>	st16 [r33]=r15		// dest
>	br.ret.sptk.many rp
>EXIT(ld16_st16)

Third time lucky, then it's time for some sleep.

extern ld16_st16(dest, src);

ENTRY(ld16_st16)
	ld16 r15=[r33]		// src
	;;
	st16 [r32]=r15		// dest
	br.ret.sptk.many rp
EXIT(ld16_st16)

