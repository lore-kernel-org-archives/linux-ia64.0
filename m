From: Sam Ravnborg <sam@ravnborg.org>
Date: Tue, 07 Oct 2003 20:46:32 +0000
Subject: Re: [PATCH] kill two dead headers
Message-Id: <marc-linux-ia64-106555967513001@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-106451477025244@msgid-missing>
In-Reply-To: <marc-linux-ia64-106451477025244@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Tue, Oct 07, 2003 at 11:44:49AM -0500, Alan Mayer wrote:
> 
> It would simplify our lives enormously if none of these patches were applied, with the possible
> exception of the last two.  They're pretty much stomping all over work already in progress or
> introducing bugs that we don't really have the time or resources to track down and fix.

Reading the above it occurs to me you are aiming for "flag-day patches".
Try to keep in sync with main-line instead is a *much* better approach.
If you are having troubles getting your patches applied, maybe it's
due to the size anyway.
See how Martin does it for S390 for example. 5-20 paches each 3 weeks in
average. And he gets good feedback - also from others than hch.
Developing everything in vacuum is the wrong approach, and does not
give you any feedback from the community - or at least you get it
only indirect with patches that hch creates.

	Sam
