From: Matthew Wilcox <willy@debian.org>
Date: Tue, 25 May 2004 20:19:14 +0000
Subject: Re: Installing kernel 2.6.6 on hp zx6000 (fwd)
Message-Id: <20040525201914.GH29154@parcelfarce.linux.theplanet.co.uk>
List-Id: <linux-ia64.vger.kernel.org>
References: <Pine.GSO.4.58.0405251608490.28567@tokyo.cc.gatech.edu>
In-Reply-To: <Pine.GSO.4.58.0405251608490.28567@tokyo.cc.gatech.edu>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Tue, May 25, 2004 at 04:09:19PM -0400, Younggyun Koh wrote:
>   LD      .tmp_vmlinux1
> /opt/gcc-3.3.3/usr/local/bin/ld: final link failed: File truncated
> make: *** [.tmp_vmlinux1] Error 1

Sure you're not out of disc space?  This has been the cause of it before
when I've seen this error message.

-- 
"Next the statesmen will invent cheap lies, putting the blame upon 
the nation that is attacked, and every man will be glad of those
conscience-soothing falsities, and will diligently study them, and refuse
to examine any refutations of them; and thus he will by and by convince 
himself that the war is just, and will thank God for the better sleep 
he enjoys after this process of grotesque self-deception." -- Mark Twain
