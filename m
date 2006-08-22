From: Christoph Lameter <clameter@sgi.com>
Date: Tue, 22 Aug 2006 16:58:35 +0000
Subject: Re: Increase default nodes shift to 10
Message-Id: <Pine.LNX.4.64.0608220957510.24252@schroedinger.engr.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <Pine.LNX.4.64.0608211908270.21433@schroedinger.engr.sgi.com>
In-Reply-To: <Pine.LNX.4.64.0608211908270.21433@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Tue, 22 Aug 2006, Horms wrote:

> 
> On Mon, 21 Aug 2006 19:11:52 -0700 (PDT), Christoph Lameter wrote:
> > We have systems with 1024 nodes and 1024 processors. Could we set
> > the default nodes shift to 10?
> 
> It seems curious to set the default to the top of the available range,
> persubably there aren't many of these systems around. Is there a
> penalty for smaller systems?

IA64 is 64 bit so 8 bit processing has no advantage.
