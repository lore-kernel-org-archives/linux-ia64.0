From: Matthew Wilcox <willy@debian.org>
Date: Mon, 08 Dec 2003 20:27:40 +0000
Subject: Re: gcc builtin memcpy is bogus?
Message-Id: <marc-linux-ia64-107091551518624@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-107090003129207@msgid-missing>
In-Reply-To: <marc-linux-ia64-107090003129207@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Mon, Dec 08, 2003 at 05:25:27PM +0100, Andreas Schwab wrote:
> - Don't use the casted address, but rather the original pointer in the
>   memcpy call.

Thanks, that works nicely.

-- 
"Next the statesmen will invent cheap lies, putting the blame upon 
the nation that is attacked, and every man will be glad of those
conscience-soothing falsities, and will diligently study them, and refuse
to examine any refutations of them; and thus he will by and by convince 
himself that the war is just, and will thank God for the better sleep 
he enjoys after this process of grotesque self-deception." -- Mark Twain
