From: Matthew Wilcox <willy@debian.org>
Date: Tue, 29 Jun 2004 14:29:27 +0000
Subject: Re: Three random questions
Message-Id: <20040629142927.GT30334@parcelfarce.linux.theplanet.co.uk>
List-Id: <linux-ia64.vger.kernel.org>
References: <40E01743.4060309@octopus.com.au>
In-Reply-To: <40E01743.4060309@octopus.com.au>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Mon, Jun 28, 2004 at 11:16:21PM -0700, David Mosberger wrote:
> It might be easier to generate assembly code.  I have done that
> occasionally but the real issue is of course that HP-UX is big-endian,
> so only endian-neutral code will work directly that way (and even so
> there may be a licensing issue with running HP-UX generated code on a
> Linux system; IANAL...).

How could that be?  That's like the wackos who thought that compiling
your code with GCC would lead to you having to release all your source
code ...

-- 
"Next the statesmen will invent cheap lies, putting the blame upon 
the nation that is attacked, and every man will be glad of those
conscience-soothing falsities, and will diligently study them, and refuse
to examine any refutations of them; and thus he will by and by convince 
himself that the war is just, and will thank God for the better sleep 
he enjoys after this process of grotesque self-deception." -- Mark Twain
