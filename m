From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Wed, 27 Mar 2002 23:47:58 +0000
Subject: Re: [Linux-ia64] Re: compiler version for kernel builds
Message-Id: <marc-linux-ia64-105590701905341@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590701905292@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590701905292@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Wed, 27 Mar 2002 15:45:39 -0800, Gary Hade <garyhade@us.ibm.com> said:

  Gary> FYI, earlier this afternoon I was able to successfully build
  Gary> and boot an IA-64 2.4.18 kernel built with: gcc version 3.1
  Gary> 20020327 (prerelease)

  Gary> The GCC problem that was previously preventing a successful
  Gary> boot was isolated by Chris McDermott and Steve Christiansen.
  Gary> It was fixed earlier today by Richard Henderson.  GCC PR 6054
  Gary> (GCC 3.1 for ia64 fails to restore gp after indirect call in
  Gary> Linux kernel)

Very good.  One thing less to worry about.

Thanks,

	--david

