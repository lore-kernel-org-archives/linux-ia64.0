From: Jesse Barnes <jbarnes@sgi.com>
Date: Tue, 25 Apr 2000 01:06:31 +0000
Subject: Re: [Linux-ia64] RPM Errors
Message-Id: <marc-linux-ia64-105590678205031@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590678205030@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590678205030@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

It might be easier to get the SRPM for ag-tools and do an 'rpm
--rebuild' on it, instead of installing all the i386 libaries to support
it.

Jesse

"Akhter, Shameem F" wrote:
> 
> Hi,
> 
> If I get the following errors, what does it really mean. Does it mean that
> the library files are not in place?
> Please let me know.
> 
> Thanks.
> 
> -- Shameem
> 
> ----------------------------------------------------------------------------
> --------
> IA64-Trillian
> ----------------------------------------------------------------------------
> --------
> 
> Script started on Tue Oct 12 04:07:52 1999
> [root@raven4 CygnusJava]# rpm --install ag-tools-1-2.i686.rpm
> error: failed dependencies:
>         binutils >= 2.9.1.0.21 is needed by ag-tools-1-2
>         cpp = 1.1.2 is needed by ag-tools-1-2
>         ld-linux.so.2 is needed by ag-tools-1-2
>         libc.so.6 is needed by ag-tools-1-2
>         libdl.so.2 is needed by ag-tools-1-2
>         libm.so.6 is needed by ag-tools-1-2
>         libpthread.so.0 is needed by ag-tools-1-2
>         libc.so.6(GLIBC_2.0) is needed by ag-tools-1-2
>         libc.so.6(GLIBC_2.1) is needed by ag-tools-1-2
>         libdl.so.2(GLIBC_2.0) is needed by ag-tools-1-2
>         libm.so.6(GLIBC_2.0) is needed by ag-tools-1-2
>         libm.so.6(GLIBC_2.1) is needed by ag-tools-1-2
>         libpthread.so.0(GLIBC_2.0) is needed by ag-tools-1-2
>         libpthread.so.0(GLIBC_2.1) is needed by ag-tools-1-2
> [root@raven4 CygnusJava]# exit
> exit
> 
> Script done on Tue Oct 12 04:08:05 1999
> 
> ----------------------------
> 
> Shameem Akhter
> 
> IACG
> IA64 Tools and Engineering
> Ph: (503) 264-1644
> 
> _______________________________________________
> Linux-IA64 mailing list
> Linux-IA64@linuxia64.org
> http://lists.linuxia64.org/lists/listinfo/linux-ia64


