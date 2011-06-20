From: "H. Peter Anvin" <hpa@zytor.com>
Date: Mon, 20 Jun 2011 16:44:25 +0000
Subject: Re: [PATCH 00/10] Enhance /dev/mem to allow read/write of arbitrary
Message-Id: <4DFF78E9.7010202@zytor.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <201106171038.25988.ptesarik@suse.cz>
	<20110617093032.GA19235@elte.hu> <4DFE7FF9.9070406@gmail.com>
	<4DFE89E0.5020509@zytor.com> <20110620074124.GB24716@elte.hu>
	<4DFF6E58.8090306@zytor.com> <20110620164045.GB10815@elte.hu>
In-Reply-To: <20110620164045.GB10815@elte.hu>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-arm-kernel@lists.infradead.org

On 06/20/2011 09:40 AM, Ingo Molnar wrote:
> 
> There is no reason why they couldnt use a .config option or a boot 
> option to get their weird stuff going, which weird stuff also happens 
> to be useful.
> 
> What i'm somewhat against is having this enabled by default for weird 
> stuff that also happens to be harmful - and the fact that it never 
> worked over 4G physical gives us the perfect opportunity to do just 
> that.
> 

I'm concerned about that notion.  I think it's fine to modularize
/dev/mem, but what we're seeing is that Red Hat and all kinds of other
entities are putting in ad hoc versions of /dev/mem, but of course doing
so incorrectly.

	-hpa

-- 
H. Peter Anvin, Intel Open Source Technology Center
I work for Intel.  I don't speak on their behalf.

