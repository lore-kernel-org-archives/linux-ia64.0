From: Stephane Eranian <eranian@frankl.hpl.hp.com>
Date: Thu, 11 Jan 2001 14:46:17 +0000
Subject: Re: [Linux-ia64] Basic query about xski
Message-Id: <marc-linux-ia64-105590693005021@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590693005020@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590693005020@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hi,

On Thu, Jan 11, 2001 at 05:17:34PM +0530, Sapariya Manish.j wrote:
> Hi,
> I am new to ia 64 as well as linux.
> I could successfully load and run ski and nue on my Linux system,
> But when i run xski from my nue promp it gives me following error.
> 
> Xlib: connection to "localhost:0,0" refused by server
> Xlib:Client is not authorised to connect to server
> Error:Cant open display localhost:0
> 

Before entering nue, you must allow connection to your Xserver for localhost:
% xhost +localhost
% nue

Even though this looks obvious, the default configuration does not take
care of that.

+--------------------------------------------------------------------+
| Ste'phane ERANIAN                       | Email eranian@hpl.hp.com |
| Hewlett-Packard Laboratories            |                          |
| 1501, Page Mill Road MS 1U-15           |                          |
| Palo  Alto, CA 94303-096                |                          |
| USA                                     |                          |
| Tel : (650) 857-7174                    |                          |
| Fax : (650) 857-5548                    |                          |
+--------------------------------------------------------------------+

