From: David Mosberger-Tang <David.Mosberger@acm.org>
Date: Tue, 27 Sep 2005 01:06:11 +0000
Subject: Re: patches added to test tree
Message-Id: <ed5aea4305092618066e40605a@mail.gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <200509160423.j8G4NCub007777@agluck-lia64.sc.intel.com>
In-Reply-To: <200509160423.j8G4NCub007777@agluck-lia64.sc.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On 9/26/05, Ian Wienand <ianw@gelato.unsw.edu.au> wrote:
> On Mon, Sep 26, 2005 at 11:22:32AM -0700, David Mosberger-Tang wrote:
> > I'm trying to use Firefox's Sage extension to track the RSS feeds.
> > Seems to work fine, but for the automated build-feed, the entries look
> > like this:
> >
> >    2.6.14-rc2 : 2005-09-26 : 17:00
> >    2.6.14-rc2:  2005-09-25 : 17:00
> >
> > which isn't very helpful.  Would it be possible to include a summary,
> > such as "9 of 9 builds succeeded" or something like that?
>
> I ditched the time because it's usually the same anyway, and added a
> summary like
>
> 2.6.14-rc2 : 2005-09-26 : [patch 3/3] [built 11/11] [boot 3/3]

Very helpful --- great!

Thanks,

  --david
