From: "Broadfoot, KenX" <kenx.broadfoot@intel.com>
Date: Mon, 13 Nov 2000 20:38:40 +0000
Subject: RE: [Linux-ia64] Recommended compiler for compiling kernels test1
Message-Id: <marc-linux-ia64-105590678205693@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590678205680@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590678205680@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Redhat 7.0 shipped with two compilers.
The new one is gcc 2.95 and it is terrible for compiling kernels. ( ia32 )

The old one is called "kgcc" and works well. ( it is egcs 2.91 ) ( again
ia32 )

I have had no trouble with gcc version 2.9-ia64 that was packaged with the
Redhat 7.0 ia64 beta.
Not sure if it is a cross-compiler though.

--ken

> -----Original Message-----
> From:	Jim Wilson [SMTP:wilson@cygnus.com]
> Sent:	Monday, November 13, 2000 12:35 PM
> To:	Pimenov, Sergei
> Cc:	linux-ia64@linuxia64.org
> Subject:	Re: [Linux-ia64] Recommended compiler for compiling kernels
> test1 0 and upper? 
> 
> >Does this compiler support cross-compilation?
> 
> Yes.  It has probably been a few months since I last built a
> cross-compiler
> myself, but other people have been building them successfully.  There was
> a
> comment from H.J. claiming that the Red Hat 7.0 ia32 OS release can't
> build a
> cross-compiler because of bugs in the compiler shipped with that release.
> Otherwise, I don't know of any specific problems.
> 
> Jim
> 
> _______________________________________________
> Linux-IA64 mailing list
> Linux-IA64@linuxia64.org
> http://lists.linuxia64.org/lists/listinfo/linux-ia64


