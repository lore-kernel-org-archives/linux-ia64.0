From: Prarit Bhargava <prarit@sgi.com>
Date: Wed, 05 Apr 2006 10:54:26 +0000
Subject: Re: [ANNOUNCE]: IA64 ISOs based on Fedora Core 5
Message-Id: <4433A1E2.5060308@sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <44332325.8050207@sgi.com>
In-Reply-To: <44332325.8050207@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

David Woodhouse wrote:
> On Tue, 2006-04-04 at 22:25 -0400, Paul Nasrat wrote:
> 
>>I assume for the weekly snapshots of rawhide that you'll be putting
>>unique (eg date based) names on the isos so they can be readily
>>identified, else you're going to run into trouble tracking issues
>>across media sets. 
> 
> 
> To be honest, I'm not convinced that weekly ISO builds are particularly
> useful -- we don't do that for rawhide on other architectures either.
> It's probably better just to encourage people to use rsync to keep up
> with rawhide, rather than downloading it all over again each week.
> 

Unfortunately, it seems I have users who are unwilling to use yum, etc., 
in the short term.  They would prefer weekly snapshots.
> 
>> Do these isos correspond with FC5 or a random snapshot?
> 
> 
> Rawhide for about a week leading up to March 20th was identical to FC5
> in all but the 'fedora-release' package. 
> 

Yep -- I replaced fedora-release with the FC5 version in the images.  I 
didn't mention it because I didn't think it was that important :).

> Aside from the updates, the next task is building Extras and Livna for
> IA64, of course...
> 

Whaddya think I'm working on? :)

P.
