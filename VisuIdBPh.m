function VisuIdBPh(varargin)
% VisuIdBPh: visualisation composite de "l'intensité" (en dB) et de la phase d'une image en amplitude complexe (English help below).
% USAGE: VisuIdBPh(ImAC,seuil_dB) ou VisuIdBph(x,y,ImAC,seuil_dB)
% x       : [OPTIONNEL] vecteur de 2 (ou n) éléments caractérisant les bornes horizontales de l'image à afficher
% y       : [OPTIONNEL] vecteur de 2 (ou m) éléments caractérisant les bornes verticales de l'image à afficher
%           Si x a plus que 2 éléments, seuls le premier et dernier élément est utilisé x=[x(1) x(end)]. Idem pour y.
%           ## x et y doivent être SIMULTANÉMENT présents ou absents. En cas d'absence, les valeurs par DÉFAUT
%           sont x=[1 n] et y=[1 m], où [m,n]=size(ImAC).    
% ImAC    : matrice complexe contenant l'image en amplitude complexe
% seuil_dB: scalaire réelle indiquant le seuil bas en dB de l'image affichée (typiquement -30 ou -40).
%           Ce seuil est RELATIF au maximum, l'image étant normalisée à 0dB (pixel à 0dB en blanc, pixel <= seuil_db en noir)
% 
% L'affichage représente le log (seuillé) de l'éclairement |ImAC|² par la luminosité de l'image et la phase sous
% la forme d'une couleur totalement saturée dans un espace de teinte périodique.
%+++++
% VisuIdBPh: Composite display of intensity on a logarithmic scale in dB and phase of a complex amplitude image.
% USE: VisuIdBPh(ImAC,thres_dB)  or  VisuIdBph(x,y,ImAC,thres_dB)
% x       : [OPTIONAL] vector of 2 (or n) elements that describes the horizontal axis limits of the image to display
% y       : [OPTIONAL] vector of 2 (or m) elements that describes the vertical axis limits of the image to display
%           If x as more than 2 elements, only the first and the last are used, i.e. x=[x(1) x(end)]. Same for y.
%           ## x and y must be SIMULTANEOUSLY present or absent. If they are missing, the default values are
%           x=[1 n] and y=[1 m], where [m,n]=size(ImAC).   
% ImAC    : complex matrix (of m×n size) that contains the complex data of the complex amplitude image to display.
% thres_dB: real scalar that gives the lower threshold, in dB, of the displayed intensity (typically -30 or -40).
%           This threshold belongs RELATIVELY to the MAXIMUM. All intensity values less or equal to this threshold will be
%           displayed in black. The maximum value, always normalized to 0dB, is displayed in white.
% 
% This program displays the complex matrix ImAC with an image that shows 10×log_10 of intensity (irradiance, |ImAC|²) with the
% pixel brightness (dB scale) and the phase with a saturated color in a periodic hue space.
%-----
% © Hervé SAUER - SupOptique - 15 avril 1999.
% + IOGS - H.S. - 24 mars 2013 : Ajout arguments optionnels x,y
% + IOGS - H.S. - 15 avril 2014: prise en compte du gamma écran et ajout "Emax=%1.1e" + correction bug remplacement fig
% + IOGS - H.S. - 26 avril 2014: suppression de la prise en compte du gamma, en fait pas judicieuse en log (dB)
% + IOGS - H.S. - 20 octobre 2014: adaptation à R2014b, correction hauteur trop grande colorbar en subplot
% + IOGS - H.S. - 21 octobre 2014: 'YDir'='norm' si x et y spécifiés, en-tête et msg_err bilingues Fr-Eng



switch nargin
  
  case 2
    AC=varargin{1};
    seuil_dB=varargin{2};
    [m,n]=size(AC);
    x=[1 n];
    y=[1 m];
    YDir='reverse'; % convention affichage d'image, l'axe y pointe vers le bas
   
  case 4
    x=varargin{1};
    y=varargin{2};
    AC=varargin{3};
    seuil_dB=varargin{4};
    YDir='normal'; % convention affichage fonction(x,y), l'axe y pointe vers le haut

  otherwise
    error(['Les seules syntaxes valides sont VisuIdBPh(ImAC,seuil_dB) et VisuIdBph(x,y,ImAC,seuil_dB)' char(10) ...
           'The only allowed calling syntaxes are VisuIdBPh(ImAC,thres_dB) and VisuIdBph(x,y,ImAC,thres_dB)']) %#ok<*CHARTEN>
end

if seuil_dB>=0
  error(['Le seuil [dB] doit être strictement négatif!' char(10)...
          'The threshold [dB] must be a strictly negative value!'])
end


% REMARQUE GÉNÉRALE: les images en vraies couleurs étant manipulées sous forme de
% tableaux à 3 dimensions de réels double précision, l'occupation mémoire peut
% rapidement devenir importante. La présente implémentation efface de manière
% systématique tout tableau temporaire dès qu'il n'a plus d'utilité.

%--------------------------------------------------------------------
% ÉTAPE 1: Création d'une image HSV (Hue Saturation Value) sous forme
%          d'un tableau Matlab à 3 dimensions.

U=real(AC.*conj(AC));
maxE=max(U(:));
seuil_eff=10^(seuil_dB/10);
V=10*log10(max(seuil_eff,U/maxE));clear U
% max sur U plutôt que sur logU pour éviter un éventuel Warning log(0)
minV=floor(min(V(:))*10)/10; % dB (le plus grand de seuil_dB ou de min(V(:))
% le max est par construction à 0dB
PlanV=(V-minV)/abs(minV); % normalisation sur [0,1]. VALUE
clear V


Ph=angle(AC); % dans ]-pi,pi].
PlanH=(Ph+pi)/(2*pi); % normalisation sur [0,1].  HUE (ou teinte en français)
clear Ph


PlanS=ones(size(AC)); % SATURATION (tjs totale)

ImHSV=cat(3,PlanH,PlanS,PlanV);       clear PlanH PlanS PlanV
% L'image HSV est crée!


%--------------------------------------------------------------------
% ÉTAPE 2: Transformation de l'image HSV en image RGB par une transformation
%          colorimétrique classique.

ImRGB=trsf_sRGB_inverse(hsv2rgb(ImHSV));                 clear ImHSV



%--------------------------------------------------------------------
% ÉTAPE 3: Affichage de l'image RGB

% ## Pour permettre de relancer VisuIdBPh sur une figure déjà créé
% par VisuIlinPh ou VisuIdBPh, quelques précautions sont nécessaires:
axIm=gca;
axTag=get(axIm,'Tag'); % A une valeur spécial si VisuI__Ph déjà utilisé
tt=get(axIm,'UserData');

tesp=0.08; tech=0.075; tbrd=0.02;
% définitions générales pour l'espacement des axes 


switch axTag
  
case {'VisuIdBPh-dB','VisuIdBPh-Ph'}
  axIm=findobj(gcf,'Tag','VisuIdBPh-Image','UserData',tt);
  if length(axIm)~=1
    error('Il y a 0 ou plusieurs images ayant le même détrompeur')
  end
  axes(axIm)
  axTag=get(axIm,'Tag');
  
case {'VisuIlinPh-lin','VisuIlinPh-Ph','VisuIlinPh-Image'}
  axs=findobj(gcf,'UserData',tt);
  tgs=get(axs,'Tag');
  if length(axs)~=3 || ~all(strncmp(tgs,'VisuIlinPh',length('VisuIlinPh')))
    error('Il n''y a pas le bon compte d''axes avec le même détrompeur')
  else
    axIm=findobj(gcf,'Tag','VisuIlinPh-Image','UserData',tt);
    if length(axIm)~=1
      error('Il y a 0 ou plusieurs images ayant le même détrompeur')
    end
    delete(setdiff(axs,axIm)) % on efface les axes des deux échelles colorées
    
    axes(axIm)
    axTag=get(axIm,'Tag');
    p=get(axIm,'Position');
    p=[p(1) p(2) p(3)/(1-2*tesp-2*tech-tbrd) p(4)];
    set(axIm,'Position',p); % On restaure la taille initiale!!
  end
  
end

%AFFICHAGE DE L'IMAGE RGB proprement dit.
figure(gcf),image(x,y,ImRGB),axis image;  clear ImRGB
set(gca,'YDir',YDir)
set(gca,'TickDir','out')


%--------------------------------------------------------------------
% ÉTAPE 4: Mise en place des échelles de teintes pour légende dB/phase
%          (si elles ne sont pas déjà en place!)

if isequal(axTag,'VisuIdBPh-Image')
  
  % Les échelles sont déjà en place.
  % Il faut juste mettre à jour les graduations de l'échelle des dB et l'affichage de Emax
  tt=get(axIm,'UserData');
  AxEdB=findobj(gcf,'Tag','VisuIdBPh-dB','UserData',tt);
  if length(AxEdB)~=1
    error('Il y a 0 ou plusieurs échelles "dB" avec le même détrompeur')
  end
  hdB=findobj(AxEdB,'type','image');
  if length(hdB)~=1
    error('Il y a 0 ou plusieurs images "échelle dB"')
  end
  set(AxEdB,'Ylim',[minV 0])
  set(hdB,'Ydata',[minV 0])
  hxLbl=get(AxEdB,'xLabel');
  set(hxLbl,'String',{'max=' sprintf('%1.1e',maxE)}) % Modification; 'FontSize' déjà appliqué sur le label

  
else
  
  % Les échelles n'existent pas. Il faut les créer.
  
  tt=now;
  
  u=get(axIm,'Units');set(axIm,'Units','Normalized');
  p=get(axIm,'Position');set(axIm,'Units',u);
  
  % tesp=0.08; tech=0.075; tbrd=0.02;  DÉFINIS PLUS HAUT
  
  pIm=[p(1) p(2) p(3)*(1-2*tesp-2*tech-tbrd) p(4)];
  pEdB=[p(1)+p(3)*(1-1*tesp-2*tech-tbrd) p(2) p(3)*tech p(4)];
  pEPh=[p(1)+p(3)*(1-tech-tbrd) p(2) p(3)*tech p(4)];
  
  set(axIm,'Position',pIm,'NextPlot','ReplaceChildren',...
    'Tag','VisuIdBPh-Image','UserData',tt)
  
  % Échelle des dB:
  axEdB=axes('position',pEdB);
  [PlanH,PlanV]=meshgrid(linspace(0,1,32),linspace(0,1,128));
  PlanS=ones(size(PlanH));
  EchHSV=cat(3,PlanH,PlanS,PlanV); clear PlanH PlanS PlanV
  % création de l'échelle "dB" en HSV
  image([0 1],[minV 0],trsf_sRGB_inverse(hsv2rgb(EchHSV))); clear EchHSV % puis affichage (en RGB).
  % minV correspond au minimum en dB de l'amplitude complexe normalisée.
  set(axEdB,'YAxisLocation','right','Xtick',[],'Ydir','normal','TickDir','out',...
    'Tag','VisuIdBPh-dB','UserData',tt,...
    'NextPlot','ReplaceChildren',...
    'Ylim',[minV 0],...
    'PlotBoxAspectRatio',[tech 0.7 1]);
  title('I_{relatif} [dB]','FontWeight','normal') % Intensité (Éclairement) relatif 
  xlabel({'max=' sprintf('%1.1e',maxE)},'FontSize',8)

  
  % Échelle des phases:
  axEPh=axes('position',pEPh);
  [PlanV,PlanH]=meshgrid(linspace(0,1,32),linspace(0,1,128));
  PlanS=ones(size(PlanH));
  EchHSV=cat(3,PlanH,PlanS,PlanV); clear PlanH PlanS PlanV
  % création de l'échelle "Phase" en HSV
  image([0 1],[-180 180],trsf_sRGB_inverse(hsv2rgb(EchHSV))); clear EchHSV % puis affichage (en RGB).
  % minV correspond au minimum en dB de l'amplitude complexe normalisée.
  set(axEPh,'YAxisLocation','right','Xtick',[],'TickDir','out',...
    'Ydir','normal','Ytick',-180:45:180, ...
    'Tag','VisuIdBPh-Ph','UserData',tt,...
    'NextPlot','ReplaceChildren',...
    'PlotBoxAspectRatio',[tech 0.7 1]);
  title(' \Phi [°]','FontWeight','normal') % le mnémonique TEX \varphi n'est pas disponible
 
  
  
  axes(axIm) % On remet l'axe courant sur l'image (pour permettre de donner un titre, ...)
  
end

end

%% function locale (pour masquer le trsf_sRGB_inverse de la BàO SupOptique et supprimer la correction du gamma écran)
function y=trsf_sRGB_inverse(x)
y=x;
end




