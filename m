From: jim@tuliptree.org
Date: Mon, 17 Mar 2003 18:11:43 +0000
Subject: Re: [Linux-ia64] Pre-emption patch for IA-64
Message-Id: <marc-linux-ia64-105590709806143@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590709806101@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590709806101@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>2.4 had a problem that seems to be a compiler issue with some AGP
>code.  I don't know whether this is the same problem, but if it is, I
>applied the following patch as a workaround:

There was a patch from Jakub Jelinek last week to address this problem.
 I don't know if it has been approved or checked in yet, but this should
be fixed soon.

    http://gcc.gnu.org/ml/gcc-patches/2003-03/msg00823.html

Jim



