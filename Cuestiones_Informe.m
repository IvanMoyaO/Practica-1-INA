  function alpha = calcAlpha(elevacion_antena, distancia_obst, elevacion_obst)
  %  elevacion_antena [=] m, distancia_obst [=] m, elevacion_obst [=] m
     alpha = (1/9) * ( 1.5 * 1/( distancia_obst/1852 ) * 3.281 * ( elevacion_obst - elevacion_antena ) - distancia_obst/1852 );
  end

  % calcula la distancia (NM)
  function distancia = calcDistancia(alpha, altitud_vuelo, elevacion_antena)
  % alpha [=] mrad, altitud_vuelo [=] ft, elevacion_antena [=] m

     p = [2/3  6*alpha -(altitud_vuelo-elevacion_antena*3.281)];

     distancia = max(roots(p));
  end

  % calcula el horizonte radio (NM)
  function mar = calcAlphaMar(elevacion_antena_m)
  % elevacion_antena_m [=] m
     elevacion_antena = elevacion_antena_m*3.281;
     syms D_t alpha_0
     eqn1 = 0 == (2/3) * D_t^2 + 6*alpha_0*D_t + elevacion_antena;
     eqn2 = elevacion_antena == (2/3) * (2*D_t)^2 + 6*alpha_0*2*D_t + elevacion_antena;

     sol = solve([eqn1,eqn2], [D_t alpha_0]);

     alpha = double(sol.alpha_0);
     H = (2/3) * 4674^2 + 6*min(alpha)*4674 + elevacion_antena;

     if ( H > 0 )
         mar = min(alpha);
     else
         mar = max(alpha);
     end
end


%% Pregunta limitación cobertura
for i = 1 : 100
    elev_antena(i) = i;
    alcance(i) = calcDistancia( calcAlphaMar(i), 5500, i)*1.852;
end
 
figure
hold on
grid on
title('Distancia Línea Vista a 5500 ft')
xlabel('Elevación Antena (m)')
ylabel('Distancia (km)')
plot(elev_antena, alcance)


%% Pregunta radial 135 fig a

for i = 1 : 100
    fl(i) = i*100;
    alcance(i) = calcDistancia( calcAlphaMar(1007), i*100, 1007)*1.852;
end

figure
hold on
grid on
title('Variación Recepción con Altitud de Vuelo (VOR a 1007 m)')
xlabel('Altitud de Vuelo (ft)')
ylabel('Alcance (km)')
plot(fl, alcance)

fprintf('A 8000 ft --> %f (km)\n', calcDistancia( calcAlphaMar(1007), 8000, 1007)*1.852)
fprintf('A 10000 ft --> %f (km)\n', calcDistancia( calcAlphaMar(1007), 10000, 1007)*1.852)