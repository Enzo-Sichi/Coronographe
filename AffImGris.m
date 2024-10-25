function AffImGris(x,y,Z)
% AffImGris: affiche un tableau RÉEL en niveaux de gris (avec coordonnées explicites et table des couleurs)
%          | displays a REAL 2D array as an image in gray level (with explicit coordinates and look-up table)
% USAGE|USE: AffImGris(x,y,Z)
% x: vecteur réel des abscisses (uniformes) de la grille des échantillons du tableau à représenter
%  | real vector that gives the horizontal coordinates of the sampling grid of the 2D data to display
% y: vecteur réel des ordonnées (uniformes) de la grille des échantillons du tableau à représenter
%  | real vector that gives the vertical coordinates of the sampling grid of the 2D data to display
% Z: matrice réelle de taille length(y)×length(x), les données 2D à représenter en niveaux de gris
%  | real matrix of size length(y)×length(x), that gives the 2D data to show in gray level.
%
% SupOptique/IOGS - Hervé Sauer.
% + IOGS - H.S. - 23 oct 2014 - adaptation pour R2014b ; en-tête et msg_err bilingue Fr-Eng
% + IOGS - H.S. - 02 avril 2018 - adaptation pour R2018a

if ~isequal(size(Z),[length(y) length(x)])
  error(['les vecteurs d''abscisses et d''ordonnées ont une taille incompatible avec celle du tableau à représenter' char(10) ...
         'Z matrix size does not match with the lengths of the x and y vectors']) %#ok<*CHARTEN>
end
if ~isreal(Z)
  error(...
    ['AffImGris NE peut PAS afficher un tableau COMPLEXE! (Utiliser abs(Z) ou angle(Z), ou les fonctions Visu… de la BàO SupOpt)' ...
     char(10) ...
     'The Z argument must be a REAL matrix and not a complex one! (Use abs(Z) or angle(Z) or Visu… IOGS tb functions)']) 
end

imagesc(x,y,Z),colormap(gca,gray(256)),axis image,colorbar,set(gca,'YDir','normal','TickDir','out') %#ok<DUALC>