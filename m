From: "Karthik Gopalakrishnan" <karthik.g.krishnan@gmail.com>
Date: Tue, 02 Jan 2007 18:54:37 +0000
Subject: Re: Kernel Build failing due to "trying to assign nonexistent symbol"
Message-Id: <5e0a1fd80701021054p92b18cas85fd2ba75834b415@mail.gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <5e0a1fd80701020523j1b699377pce0c4d86723967a9@mail.gmail.com>
In-Reply-To: <5e0a1fd80701020523j1b699377pce0c4d86723967a9@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On 1/2/07, Matthew Wilcox <matthew@wil.cx> wrote:
> On Tue, Jan 02, 2007 at 06:53:37PM +0530, Karthik Gopalakrishnan wrote:
> >    I have added a few new files in the console directory to try to
> > support a new console device. I am trying to get them to compile. I
> > have made the necessary   obj-${CONFIG_FUNC_FOO}  += foo_file.o
> > change to the Makefile in the "/drivers/video/console/" directory. I
> > have also set CONFIG_FUNC_FOO=y in the .config file. However, when I
> > try to build the kernel, I get the following message.
>
> You need to add a Kconfig stanza for FUNC_FOO.  Look in
> drivers/video/console/Kconfig for examples.
>
Oh my... Blunder on my part. Thanks.

Regards,
Karthik
