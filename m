From: Zou Nan hai <nanhai.zou@intel.com>
Date: Thu, 17 Aug 2006 22:55:36 +0000
Subject: Re: [patch 3/5] git-ia64 versus genirq
Message-Id: <1155855336.2585.1244.camel@linux-znh>
List-Id: <linux-ia64.vger.kernel.org>
References: <20060817071455.164893000@tabatha.lab.ultramonkey.org>
In-Reply-To: <20060817071455.164893000@tabatha.lab.ultramonkey.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Thu, 2006-08-17 at 21:58, Eric W. Biederman wrote:
> Horms <horms@verge.net.au> writes:
> 
> > On Thu, 17 Aug 2006 00:28:53 -0700, Andrew Morton wrote:
> >> On Thu, 17 Aug 2006 16:07:22 +0900
> >> horms@tabatha.lab.ultramonkey.org wrote:
> >> 
> >>> > commit 1f4c5c1fe2a6a74271989ec079af11e2bb8e2826
> >>> > tree a0da63a3dcc3ffd71653ecc039db416dbcaa86d4
> >>> > parent beada884dd437b509c26b39f1a0b0c6b31e6f340
> >>> > author Andrew Morton <akpm@osdl.org> 1151573360 -0700
> >>> > committer Tony Luck <tony.luck@intel.com> 1151607053 -0700
> >>> > 
> >>> > [IA64] git-ia64 versus genirq
> >>> > 
> >>> > Fix the git-ia64 tree after genirq merge.
> >>> > 
> >>> > Signed-off-by: Andrew Morton <akpm@osdl.org>
> >>> > Signed-off-by: Tony Luck <tony.luck@intel.com>
> >>> 
> >>> Patch from test branch of Tony Luck's ia64 tree.
> >>> This is needed for ia64 kexec in Linus's tree.
> >>> 
> >> 
> >> I think you're telling us that Tony needs to get this into mainline, yes?
> >
> > This would be ia64 kexec.
> >
> > I was thinking more along the lines that it would be nice if Zou Nan hai
> > sent incremental patches against Tony's tree. But he probably gets more
> > testing by sending out a apply and forget patch against 2.6.18-rc4. And
> > certainly merging ia64 kexec into Linus' tree would be a nice resolution
> > to this problem.
> >
> > At OLS Tony spoke about what state he would like to see kexec in before
> > it is merged into Linus' tree. Basically reports that it works on
> > at least a cople of different vendor's gear. That is proving harder
> > than one might have hoped. But the code is marked as experimental,
> > and if pushing it into Linus's tree both makes patch management a bit
> > easier, and potentially gives the code better testing, then it seems
> > like a good idea to me.
> 
> Guys I have a serious problem with this patchset.
> 

Hi Eric,
	That based patchset was post days before the OLS....
	I have a much crash path simplified patch set posted a few days before.
	http://www.gelato.unsw.edu.au/archives/linux-ia64/0608/18790.html
	I agree that we should have minmal code in crash path.
	I am trying to simplify that patch set more.

Thanks
Zou Nan hai 

	
	
