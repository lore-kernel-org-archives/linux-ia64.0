From: Matthew Wilcox <willy@debian.org>
Date: Fri, 06 Feb 2004 12:24:27 +0000
Subject: Re: q-tools-0.0 released
Message-Id: <20040206122427.GJ24334@parcelfarce.linux.theplanet.co.uk>
List-Id: <linux-ia64.vger.kernel.org>
References: <20040205215009.GA2316@cup.hp.com>
In-Reply-To: <20040205215009.GA2316@cup.hp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Thu, Feb 05, 2004 at 11:26:47PM -0800, Stephane Eranian wrote:
> Grant,
> 
> On Thu, Feb 05, 2004 at 09:05:21PM -0800, Grant Grundler wrote:
> > On Thu, Feb 05, 2004 at 02:57:22PM -0800, Stephane Eranian wrote:
> > > You need to have libpfm-3.0 installed on your system.
> > > I think Al Stone published the package on the Debian sites.
> > > You need the development + runtime packages.
> > 
> > Stephane,
> > Yes, he did.
> > Debian currently has:
> > ii  libpfm         2.0-6          IA-64 Performance Monitor (PMU) -- runt-time
> > ii  libpfm-dev     2.0-6          IA-64 Performance Monitor (PMU) -- developme
> > ii  pfmon          3.0-2          a performance monitoring tool for Linux/ia64
> > 
> > The pfmon from debian was probably built against "2.0-6" libpfm.
> That's wrong. I don't event think it compiles that way.
> 
> > Is that bad?
> Yes, it is. there should be a libpfm_3.0 and libpfm-dev_3.0 packages.

Looks like the Debian packages have some problems:

Package: pfmon
Depends: libc6.1 (>= 2.3.2.ds1-4), libelfg0, libpfm2, libpfm3
$ sudo apt-get install pfmon
The following packages have unmet dependencies:
  pfmon: Depends: libpfm2 but it is not installable
         Depends: libpfm3 but it is not installable

Al, what's up?

-- 
"Next the statesmen will invent cheap lies, putting the blame upon 
the nation that is attacked, and every man will be glad of those
conscience-soothing falsities, and will diligently study them, and refuse
to examine any refutations of them; and thus he will by and by convince 
himself that the war is just, and will thank God for the better sleep 
he enjoys after this process of grotesque self-deception." -- Mark Twain
