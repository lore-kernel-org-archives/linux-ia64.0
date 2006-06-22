From: Horms <horms@verge.net.au>
Date: Thu, 22 Jun 2006 03:28:09 +0000
Subject: Re: patches added to release/test trees
Message-Id: <20060622032809.DCA7F3409A@koto.vergenet.net>
List-Id: <linux-ia64.vger.kernel.org>
References: <200601270107.k0R17838011430@agluck-lia64.sc.intel.com>
In-Reply-To: <200601270107.k0R17838011430@agluck-lia64.sc.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

In article <200606212319.k5LNJw7e014316@agluck-lia64.sc.intel.com> you wrote:
> 
> Horms and Ian.  Thanks for all the kexec patches you've posted.  I'll
> be folding them in on top of the current kexec stuff soon.  There
> still seem to be a lot of open issues on this, and hardly any reports
> of any testing going on.  At this pace kexec/kdump will be sitting in
> "test" (and -mm) for at least another release cycle.

Hi Tony,

thanks for the feedback. I understand that kexec/kdump is quite
green/flakey and having it sit in test as you suggest is quite
approtiate in my oppinion too. Hopefully its quality can improve over
time.

As for the patches that I have sent, let me know if you need any of them
rediffed or reworked. I'm more than happy to do that kind of leg work,
as some of the patches conflict in minor ways, and some of them are
against the kdump patch before it went into your tree, and thus may need
some minor merging.

Thanks

-- 
Horms                                           http://www.vergenet.net/~horms/

