From: Neil Brown <neilb@cse.unsw.edu.au>
Date: Tue, 21 Oct 2003 03:37:38 +0000
Subject: Re: IA64 ino_t incorrectly sized?
Message-Id: <marc-linux-ia64-106670768420915@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-106378281914262@msgid-missing>
In-Reply-To: <marc-linux-ia64-106378281914262@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Friday October 17, nathans@sgi.com wrote:
> hi Neil,
> 
> On Fri, Oct 17, 2003 at 10:47:14AM +1000, Neil Brown wrote:
> > I don't really want __kernel_old_ino_t as it would clutter every arch
> > just for nfsd, and just for 2.6.
> 
> OK sounds good, although we'd like these changes in 2.4 too
> (eventually).  Do these patches look acceptable?
> 

Yes, I am happy with those.

NeilBrown

> thanks.
> 
> -- 
> Nathan
> --- /usr/tmp/TmpDir.1899229-0/linux/include/linux/nfsd/syscall.h_1.11	Fri Oct 17 11:42:05 2003
> +++ linux/include/linux/nfsd/syscall.h	Fri Oct 17 11:13:35 2003
> @@ -22,6 +22,16 @@
>  #include <linux/nfsd/auth.h>
>  
>  /*
> + * ABI compatibility type definition for the IA64 __kernel_ino_t.
> + * This can be removed along with the nfsctl_export syscall (2.7).
> + */
> +#ifdef __ia64__
> + typedef unsigned int	__nfsd_ino_t;
> +#else
> + typedef __kernel_ino_t	__nfsd_ino_t;
> +#endif
> +
> +/*
>   * Version of the syscall interface
>   */
>  #define NFSCTL_VERSION		0x0201
> @@ -60,7 +70,7 @@
>  	char			ex_client[NFSCLNT_IDMAX+1];
>  	char			ex_path[NFS_MAXPATHLEN+1];
>  	__kernel_old_dev_t	ex_dev;
> -	__kernel_ino_t		ex_ino;
> +	__nfsd_ino_t		ex_ino;
>  	int			ex_flags;
>  	__kernel_uid_t		ex_anon_uid;
>  	__kernel_gid_t		ex_anon_gid;
> --- /usr/tmp/TmpDir.1959-0/linux/include/linux/nfsd/syscall.h_1.6	Fri Oct 17 11:56:38 2003
> +++ linux/include/linux/nfsd/syscall.h	Fri Oct 17 11:56:14 2003
> @@ -22,6 +22,17 @@
>  #include <linux/nfsd/auth.h>
>  
>  /*
> + * ABI compatibility type definition for the IA64 __kernel_ino_t.
> + * This can be removed along with the nfsctl_export syscall (2.7)
> + * and the nfsctl_fhparm syscall (2.5).
> + */
> +#ifdef __ia64__
> + typedef unsigned int	__nfsd_ino_t;
> +#else
> + typedef __kernel_ino_t	__nfsd_ino_t;
> +#endif
> +
> +/*
>   * Version of the syscall interface
>   */
>  #define NFSCTL_VERSION		0x0201
> @@ -60,7 +71,7 @@
>  	char			ex_client[NFSCLNT_IDMAX+1];
>  	char			ex_path[NFS_MAXPATHLEN+1];
>  	__kernel_dev_t		ex_dev;
> -	__kernel_ino_t		ex_ino;
> +	__nfsd_ino_t		ex_ino;
>  	int			ex_flags;
>  	__kernel_uid_t		ex_anon_uid;
>  	__kernel_gid_t		ex_anon_gid;
> @@ -81,7 +92,7 @@
>  struct nfsctl_fhparm {
>  	struct sockaddr		gf_addr;
>  	__kernel_dev_t		gf_dev;
> -	__kernel_ino_t		gf_ino;
> +	__nfsd_ino_t		gf_ino;
>  	int			gf_version;
>  };
>  
