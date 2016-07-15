{$L-}
{*=========================================================================*}
{*                 Constants for engine for 552 main processor.            *}
{*=========================================================================*}
{*                                                                         *}
{*      These are constant used in 552 main processor.                     *}
{*                                                                         *}
{*      Author: Clayton B. Sims                                            *}
{*                                                                         *}
{*      Date:   03/05/90                Last Changed:                      *}
{*                                                                         *}
{*=========================================================================*}

const
  OK    = 0;
  ERROR = 12;

{*=========================================================================*}
{* Catastrophic error codes                                                *}
{*=========================================================================*}
const

  UNDERFLOW  =  0;
  OVERFLOW   =  1;
  SHOULDNOT  =  2;
  UNDEFINED  =  3;
  BADHEX     =  4;

{*=========================================================================*}
{* Engine memory parmaters.                                                *}
{*=========================================================================*}
const
  STACKMAX = $800;      { Developer: fiddle, but don't go over 32767 }
  CODEMAX  = $1000;     { Developer: fiddle, but don't go over 32767 }

  DUMMYRET = $FFFF;     { Dummy return pushed by INIT                }


{$L+}
