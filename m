From: Matthew Wilcox <matthew@wil.cx>
Date: Tue, 05 Dec 2006 13:35:51 +0000
Subject: Re: ia64 Kernel Configuration HowTo
Message-Id: <20061205133549.GM3013@parisc-linux.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <5e0a1fd80612050520qe3ad6e1t78298582eed49b5c@mail.gmail.com>
In-Reply-To: <5e0a1fd80612050520qe3ad6e1t78298582eed49b5c@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Tue, Dec 05, 2006 at 06:50:51PM +0530, Karthik Gopalakrishnan wrote:
> Hi Folks.
> 
>    When I do a 'make config' before building the Kernel, I am faced
> with tons of options. Some I understand. Some, I have no clue to even
> make an educated guess. Could you please point me to a document that
> explains what each of the options there stand for.

You know that you can enter '?' at the prompt and get help for each one,
right?

I'd recommend starting from something like, say, zx1_defconfig (if you
have an HP) or sn2_defconfig (if you have an SGI), and tweak it from
there as you need.  Just run 'make zx1_defconfig' and you'll have many
fewer questions to answer.

You can also run 'make help' and it'll tell you a lot of other things
you can do.
