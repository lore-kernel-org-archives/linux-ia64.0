From: Stephane Eranian <eranian@hpl.hp.com>
Date: Thu, 14 Aug 2003 00:09:06 +0000
Subject: EFI boot manager fail-over behavior question
Message-Id: <marc-linux-ia64-106081992104989@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hi,

I am trying to verify the behavior of the EFI boot manager described
in the EFI specific (Chapter 3). It is said that if a boot option
executes and returns with an error code different from EFI_SUCCESS, the
boot manager will pick the next option in the boot order and execute
it. This goes on until the boot manager runs out of options, a nice
built in fail-over mechanism.

I wanted to verify this behavior for elilo. I have the following
order:

EFI Boot Manager ver 1.10 [14.61]  Firmware ver 2.00 [4318]

Please select a boot option

    EFI Shell [Built-in]                                            
    netboot                                                         
    Debian GNU/Linux                                                
    Boot Option Maintenance Menu                                    
    System Configuration Menu                                       

Then I select netboot, and make elilo fail. It exists with EFI_LOAD_ERROR.
The correct return value is produced by elilo because I get:

ELILO boot: sdklfjasdflkasj
elilo.c(line 70):Kernel file  not found sdklfjasdflkasj
Start of netboot failed: Load Error
Paused - press any key to continue 

Then I press a key and I go back to the menu, the next option (Debian)
is not triggered. 

My guess is that because it is waiting for me to press a key, it assumes
interactive mode, therefore the boot manager does not go to the next option.

Why is this message printed? Maybe because I am at the bottom of the page.
I have seen the boot manager occasionally doing the right thing but I can't
figure out what the logic is. The 'bottom of the page' key press message
makes some sense when you don't want to loose error messages printed
on the console. But then it is not quite what you want if going to the next
option is what you really want, i.e. fail-over behavior.

Could somebody more familiar than me  with the boot manager clarify this?


Thanks.

--
-Stephane
