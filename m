From: Ian Wienand <ianw@gelato.unsw.edu.au>
Date: Tue, 23 Sep 2003 23:04:12 +0000
Subject: Re: NS83820 2.6.0-test5 driver seems unstable on IA64
Message-Id: <marc-linux-ia64-106435829928363@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-106394503001622@msgid-missing>
In-Reply-To: <marc-linux-ia64-106394503001622@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Tue, Sep 23, 2003 at 10:27:35AM -0700, David S. Miller wrote:
> As I understand it, you even do this stupid printk for user apps
> as well, that makes it more than rediculious.
                                                                                                                                                      
Just as a point of interest, as an application programmer I think it's
the type of thing you want to know about quite loudly.  The only
benchmark style figure on this I've ever seen is in this paper
                                                                                                                                                      
http://msdn.microsoft.com/library/default.asp?url=/library/en-us/dv_vstechart/html/vcconWindowsDataAlignmentOnIPFX86X86-64.asp
                                                                                                                                                      
(forgive the long url) which, if you scroll down to the little graph,
shows OS fixup is about 450 times slower that an aligned access.  That
sucks, and if I didn't realise I'd done it, it would suck even more.

Oh, and I think fixing it up automatically & warning is much more
useful than sending a (by default) terminating signal to the program;
though I'm sure others might disagree.
                                                                                                                                                      
-i
ianw@gelato.unsw.edu.au
http://www.gelato.unsw.edu.au
